#
#   This is using the tidymodels approach to tune and run some models.
#   This is taking up quite a bit of memory and is thus hard to run in parallel.
#   Probably delete...
#

library(tidyverse)
library(tidymodels)
library(randomForest)
library(doFuture)
library(here)

setwd(here::here("tuning-experiments"))

registerDoFuture()
plan(multiprocess(workers = 6))

df <- read_rds("trafo-data/1mo_data.rds") %>%
  mutate(incidence_civil_ns_plus1 = factor(incidence_civil_ns_plus1, levels = c("1", "0")))

dv <- "incidence_civil_ns_plus1"

escalation <- c(
  "gov_opp_low_level",
  "gov_reb_low_level",
  "opp_gov_low_level",
  "reb_gov_low_level",
  "gov_opp_nonviol_repression",
  "gov_reb_nonviol_repression",
  "gov_opp_accommodations",
  "gov_reb_accommodations",
  "reb_gov_demands",
  "opp_gov_demands"
)

all_cameo <- c(
  names(df)[str_detect(names(df), "cameo_[0-9]+$")]
)

# Make sure we are operating on same df for both specs
df <- df[complete.cases(df[, unique(c(dv, escalation, all_cameo))]), ]

# Define training and testing sets for base specification
train_period = mean(df$period[which(df$month==12 & df$year==2007)])
end_period = mean(df$period[which(df$month==12 & df$year==2015)])

train_df <- df[df$period<=train_period,]
test_df  <- df[df$period>train_period & df$period<=end_period,]

continue <- TRUE
while(continue) {
  folds <- vfold_cv(train_df, v = 3, repeats = 4)
  pos_events <- map_dbl(folds$splits, function(x) {dat = testing(x); sum(dat[[dv]]=="1")})
  if (all(pos_events > 0)) continue <- FALSE
}

tune_spec <-
  rand_forest(trees = tune(),
              mtry = tune(),
              min_n = tune()) %>%
  set_engine("randomForest") %>%
  set_mode("classification")

wf_escalation <- workflow() %>%
  add_model(tune_spec) %>%
  add_formula(as.formula(paste0(dv, " ~ ", paste0(escalation, collapse = " + "))))

hp_grid <- grid_random(
  trees(range = c(1000, 10000)),
  mtry(range = c(1, 6)),
  min_n(range = c(1, 50)),
  size = 20)

tune_res <-
  wf_escalation %>%
  tune_grid(
    resamples = folds,
    grid = hp_grid,
    metrics = metric_set(mn_log_loss, roc_auc, pr_auc)
  )

write_rds(tune_res, "output/tune-res.rds")

