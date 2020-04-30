#
#   Run a subset of the B&S models/specifications along with modified versions
#   that use alternative RF hp settings; obtain training CV fit and test fit
#
#   This script in essence generates AUC-ROC values to complement the
#   information in Table 1.
#

library(tidyverse)
library(tidymodels)
library(randomForest)
library(future)
library(doFuture)
library(here)
library(lgr)
library(boot)

setwd(here::here("tuning-experiments"))

registerDoFuture()
plan(multisession(workers = 7))

#
#   Set up model function ----
#   _______________________
#
#   I'm going to define a couple of model functions here. In Table 1 in the
#   paper, the results are identified by 3 dimensions:
#
#     - forecast horizon: 1 month or 6 month
#     - settings, what B&S call "specification": variations in RF
#       hyperparameters, train/test splits, and DV coding
#     - feature sets, what I will call specification: the columns used as
#       predictors, e.g. escalation, CAMEO
#
#   So a result cell in the table is identified by [horizon, setting, spec].
#
#   I am interested in two things:
#
#     - adding a RF model version that uses alternative hyperparameter settings
#     - obtaining cross-validated OOS fit for the training data split
#
#   Since the setting dimension includes both changes in the RF settings and
#   changes in the data, adding another RF setting choice kind of requires
#   splitting this dimension into RF settings vs. data changes. Maybe for now
#   it's just easier to ignore this and add "another row".
#
#   I'm also going to only do this for 1 month for now. What makes sense then
#   for the sake of flexibility is to encapsulate the model [setting] in a
#   function but allow the feature specification [spec] and training data to
#   vary
#
#     rf_[setting](data, features = [spec], horizon = 1mo)
#

# Base specification
#
# Corresponds to the settings in the first row in Table 1
#
# examples
#
# mdl    <- rf_base(train_df, escalation)
# phat   <- predict.rf_base(mdl, train_df)
# pcheck <- mdl$predicted
# cor(phat, pcheck)
# # the correlation is a bit less than 1. This also happens with the examples
# # in ?randomForest
#
rf_base <- function(data, features) {
  suppressWarnings({
    randomForest(y = as.integer(data$incidence_civil_ns_plus1=="1"),
                 x = data[, features],
                 type = "regression",
                 ntree = 100000,
                 maxnodes = 5,
                 sampsize = 100,
                 replace = FALSE,
                 do.trace = FALSE)
  })
}

predict.rf_base <- function(object, new_data, ...) {
  # predict.randomForest checks for missing values in new_data before selecting
  # the columns that are actually needed. So if there are missing values in
  # unneeded columns, this will still cause an error.
  new_data <- new_data[, rownames(object$importance)]
  as.vector(predict(object, newdata = new_data, type = "response"))
}


# Default RF
#
# RF with out of the box hyperparameter settings
#
# example
#
# mdl    <- rf_default(train_df, escalation)
# phat   <- predict.rf_default(mdl, train_df)
rf_default <- function(data, features) {
  stopifnot(is.factor(data$incidence_civil_ns_plus1))
  randomForest(y = data$incidence_civil_ns_plus1,
               x = data[, features],
               type = "classification",
               do.trace = FALSE)
}

predict.rf_default <- function(object, new_data, ...) {
  new_data <- new_data[, rownames(object$importance)]
  as.vector(predict(object, newdata = new_data, type = "prob")[, "1"])
}

# Tuned RF
#
# RF with tuned hyperparameters
#
# example
#
# mdl    <- rf_tuned(train_df, escalation)
# phat   <- predict.rf_tuned(mdl, train_df)
rf_tuned <- function(data, features) {
  stopifnot(is.factor(data$incidence_civil_ns_plus1))
  randomForest(y = data$incidence_civil_ns_plus1,
               x = data[, features],
               type = "classification",
               ntree = 10000,
               mtry  = floor(sqrt(length(features))),
               nodesize = 1,
               do.trace = FALSE)
}

predict.rf_tuned <- function(object, new_data, ...) {
  new_data <- new_data[, rownames(object$importance)]
  as.vector(predict(object, newdata = new_data, type = "prob")[, "1"])
}



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

quad <- c(
  "gov_opp_vercf","gov_reb_vercf",
  "gov_opp_matcf","gov_reb_matcf",
  "opp_gov_vercf","reb_gov_vercf",
  "opp_gov_matcf","reb_gov_matcf",
  "gov_opp_vercp","gov_reb_vercp",
  "gov_opp_matcp","gov_reb_matcp",
  "opp_gov_vercp","reb_gov_vercp",
  "opp_gov_matcp","reb_gov_matcp"
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


#
#   Training data CV ----
#   _________________

set.seed(5235)
folds <- vfold_cv(train_df, v = 2, repeats = 7*3)
map_dbl(folds$splits, function(x) {dat = testing(x); sum(dat[[dv]]=="1")})

res <- foreach(i = 1:nrow(folds)) %dopar% {
  lgr$info("Iteration %s of %s", i, nrow(folds))
  res_i <- list()

  train_i <- training(folds$splits[[i]])
  test_i  <- testing(folds$splits[[i]])

  #
  #   Escalation spec
  #

  # Base escalation model (cf. first row in Table 1)
  fitted_base     <- rf_base(train_i, escalation)
  test_preds_base <- tibble(
    preds = predict.rf_base(fitted_base, test_i),
    truth = test_i[, dv]
  )

  res_i <- c(res_i, list(
    tibble(i = i,
           model = "base escalation",
           AUC = roc_auc(test_preds_base, truth, preds)[[".estimate"]]
    )))

  # RF with default settings, escalation features
  fitted_default     <- rf_default(train_i, escalation)
  test_preds_default <- tibble(
    preds = predict.rf_default(fitted_default, test_i),
    truth = test_i[, dv]
  )

  res_i <- c(res_i, list(
    tibble(i = i,
           model = "default escalation",
           AUC = roc_auc(test_preds_default, truth, preds)[[".estimate"]]
    )))

  # RF with tuned settings, escalation features
  fitted_tuned     <- rf_tuned(train_i, escalation)
  test_preds_tuned <- tibble(
    preds = predict.rf_tuned(fitted_tuned, test_i),
    truth = test_i[, dv]
  )

  res_i <- c(res_i, list(
    tibble(i = i,
           model = "tuned escalation",
           AUC = roc_auc(test_preds_tuned, truth, preds)[[".estimate"]]
    )))

  #
  #   Quad spec
  #

  # Base quad model (cf. first row in Table 1)
  fitted_base     <- rf_base(train_i, quad)
  test_preds_base <- tibble(
    preds = predict.rf_base(fitted_base, test_i),
    truth = test_i[, dv]
  )

  res_i <- c(res_i, list(
    tibble(i = i,
           model = "base quad",
           AUC = roc_auc(test_preds_base, truth, preds)[[".estimate"]]
    )))

  # RF with default settings, quad features
  fitted_default     <- rf_default(train_i, quad)
  test_preds_default <- tibble(
    preds = predict.rf_default(fitted_default, test_i),
    truth = test_i[, dv]
  )

  res_i <- c(res_i, list(
    tibble(i = i,
           model = "default quad",
           AUC = roc_auc(test_preds_default, truth, preds)[[".estimate"]]
    )))

  # RF with tuned settings, quad features
  fitted_tuned     <- rf_tuned(train_i, quad)
  test_preds_tuned <- tibble(
    preds = predict.rf_tuned(fitted_tuned, test_i),
    truth = test_i[, dv]
  )

  res_i <- c(res_i, list(
    tibble(i = i,
           model = "tuned quad",
           AUC = roc_auc(test_preds_tuned, truth, preds)[[".estimate"]]
    )))

  #
  #   Pull together results
  #
  res_i <- bind_rows(res_i)
  res_i
}

res <- bind_rows(res)
write_rds(res, "output/train-cv-resamples.rds")

boot_ci <- function(x) {
  bb <- boot(x, function(x, indices) mean(x[indices]), R = 2000)
  ci <- boot.ci(bb, type = "basic")
  out <- as.list(ci$basic[4:5])
  names(out) <- c("ci_lower", "ci_upper")
  as_tibble(out)
}

cv_fit <- res %>%
  group_by(model) %>%
  summarize(mean_AUC = mean(AUC),
            sd_AUC   = sd(AUC),
            ci = list(boot_ci(AUC))) %>%
  unnest(ci)

tbl <- cv_fit %>%
  mutate(Test_ROC_AUC = rep(NA, nrow(cf_fit)))


#
#   Run models on full training data and get test fit ----
#   _________________________________________________

# Estimate the final models on the full training data

#
#   Escalation spec
#

# Base escalation model (cf. first row in Table 1)
fitted_base     <- rf_base(train_df, escalation)
test_preds_base <- tibble(
  preds = predict.rf_base(fitted_base, test_df),
  truth = test_df[, dv]
)

tbl$Test_ROC_AUC[1] <- roc_auc(test_preds_base, truth, preds)[[".estimate"]]

# Default RF escalation model
fitted_default     <- rf_default(train_df, escalation)
test_preds_default <- tibble(
  preds = predict.rf_default(fitted_default, test_df),
  truth = test_df[, dv]
)

tbl$Test_ROC_AUC[2] <- roc_auc(test_preds_default, truth, preds)[[".estimate"]]

# Tuned RF escalation model
fitted_tuned     <- rf_tuned(train_df, escalation)
test_preds_tuned <- tibble(
  preds = predict.rf_tuned(fitted_tuned, test_df),
  truth = test_df[, dv]
)

tbl$Test_ROC_AUC[3] <- roc_auc(test_preds_tuned, truth, preds)[[".estimate"]]

#
#   Quad spec
#

# Base quad model (cf. first row in Table 1)
fitted_base     <- rf_base(train_df, quad)
test_preds_base <- tibble(
  preds = predict.rf_base(fitted_base, test_df),
  truth = test_df[, dv]
)

tbl$Test_ROC_AUC[4] <- roc_auc(test_preds_base, truth, preds)[[".estimate"]]

# Default RF quad model
fitted_default     <- rf_default(train_df, quad)
test_preds_default <- tibble(
  preds = predict.rf_default(fitted_default, test_df),
  truth = test_df[, dv]
)

tbl$Test_ROC_AUC[5] <- roc_auc(test_preds_default, truth, preds)[[".estimate"]]

# Tuned RF quad model
fitted_tuned     <- rf_tuned(train_df, quad)
test_preds_tuned <- tibble(
  preds = predict.rf_tuned(fitted_tuned, test_df),
  truth = test_df[, dv]
)

tbl$Test_ROC_AUC[6] <- roc_auc(test_preds_tuned, truth, preds)[[".estimate"]]

# mdl_escalation_3 <- suppressWarnings({
#   randomForest(y = as.integer(train_df$incidence_civil_ns_plus1=="1"),
#                x = train_df[, all_cameo],
#                type = "regression",
#                ntree = 100000,
#                maxnodes = 5,
#                sampsize = 100,
#                replace = FALSE,
#                do.trace = FALSE)
# })
#
# test_preds_3 <- tibble(
#   preds = as.vector(predict(mdl_escalation_3, newdata = test_df[, all_cameo],
#                             type = "response")),
#   truth = test_df[, dv])
# tbl$Test_ROC_AUC[3] <- roc_auc(test_preds_3, truth, preds)[[".estimate"]]
#
#
#
# mdl_escalation_4 <- randomForest(y = train_df$incidence_civil_ns_plus1,
#                                  x = train_df[, all_cameo],
#                                  type = "classification",
#                                  ntree = 5000,
#                                  mtry  = 3,
#                                  replace = TRUE,
#                                  do.trace = FALSE)
#
# test_preds_4 <- tibble(
#   preds = as.vector(predict(mdl_escalation_4, newdata = test_df[, escalation], type = "prob")[, "1"]),
#   truth = test_df[, dv])
# tbl$Test_ROC_AUC[4] <- roc_auc(test_preds_4, truth, preds)[[".estimate"]]

write_rds(tbl, "output/test-auc-roc.rds")


tbl


# Difference of means test. Are the base and modified model AUC scores in the
# train CV different?
t.test(AUC ~ model, data = res[res$model %in% c("base escalation", "default escalation"), ])
# yep, p < 0.05 thus model 1 performs better than model 2.

t.test(AUC ~ model, data = res[res$model %in% c("base escalation", "tuned escalation"), ])

# Roc curve for first escalation baseline model
roc_escalation <- roc_curve(test_preds_base, truth, preds)
autoplot(roc_escalation)

# the roc curve has a big kink because a bunch of cases have identical prediction
test_preds_base %>% count(preds) %>% arrange(desc(n))





