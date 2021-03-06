#
#   Tuning experiments
#
#   This script loops over a hyperparameter grid for the escalation model,
#   using repeated CV on the origintal training data.
#
#   One NOTE: this is run in parallel and somehow the worker sessions end up
#   consuming a lot of memory (>10GB). So I'm using rm() throughout this
#   script to remove objects no longer needed.
#

WORKERS <- 7
horizon <- "6 months"
spec    <- "cameo"
hp_samples <- 100

library(readr)
library(tibble)
library(tidyr)
library(dplyr)
library(purrr)
library(stringr)
library(ggplot2)
library(rsample)       # for vfold_cv
library(yardstick)
library(randomForest)
library(future)
library(doFuture)
library(here)
library(lgr)

lgr$info("Start tuning script")
t0 = proc.time()

# Determine machine this is running on (for timings)
machine <- "unknown"
if (Sys.info()["sysname"]=="Windows" & Sys.info()["user"]=="andybega") {
  machine <- "andy msi"
} else if (Sys.info()["sysname"]=="Darwin" & Sys.info()["user"]=="andybega") {
  machine <- "andy mbp"
}

setwd(here::here("tuning-experiments"))

registerDoFuture()
plan("multisession", workers = WORKERS)


# tune result output file name
tune_res_filename <- paste(horizon, spec, sep = "-")
tune_res_filename <- gsub("[_ ]", "-", tune_res_filename)
# determine batch id
files <- dir("output/batches")
files <- files[str_detect(files, tune_res_filename)]
batch_id <- length(files) + 1
tune_res_filename <- paste0(tune_res_filename, "-", batch_id, ".rds")



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

goldstein <- c(
  "gov_opp_gold","gov_reb_gold",
  "opp_gov_gold","reb_gov_gold"
)

cameo <- c(
  names(df)[str_detect(names(df), "cameo_[0-9]+$")]
)


# Setup 1-month or 6-month data -------------------------------------------

if (horizon=="1 month") {

  # Make sure we are operating on same df for both specs
  df <- df[complete.cases(df[, unique(c(dv, escalation, cameo))]), ]

  # Need to sort the df by year and month (implicitly period, which is a unique
  # ID for year-month), otherwise the train/test indices will be wrong
  data_1mo <- data_1mo %>% arrange(year, month, country_iso3)

  # Define training and testing sets for base specification
  train_period = mean(df$period[which(df$month==12 & df$year==2007)])
  end_period = mean(df$period[which(df$month==12 & df$year==2015)])

  train_df <- df[df$period<=train_period,]
  test_df  <- df[df$period>train_period & df$period<=end_period,]

} else {

  data_6mo <- read_rds("trafo-data/6mo_data.rds") %>%
    mutate(incidence_civil_ns_plus1 = factor(incidence_civil_ns_plus1, levels = c("1", "0")))

  # Make sure we are operating on same df for both specs
  data_6mo <- data_6mo[complete.cases(data_6mo[, unique(c(dv, escalation, cameo))]), ]

  # Need to sort the df by year and period (implicitly period, which is a unique
  # ID for half-year), otherwise the train/test indices will be wrong
  data_6mo <- data_6mo %>% arrange(year, period, country_iso3)

  # Define training and testing sets for base specification
  # periods are from +master.R
  train_df <- data_6mo[data_6mo$period<=14, ]
  test_df  <- data_6mo[data_6mo$period>14 & data_6mo$period<=30, ]

}

rm(df, test_df, data_6mo)

#
#   HP tuning ----
#   _______________


if (horizon=="1 month") {
  if (spec=="escalation") {
    hp_grid <- tibble(
      tune_id  = 1:hp_samples,
      mtry     = as.integer(round(runif(hp_samples, 2, 5))),
      ntree    = as.integer(round(runif(hp_samples, 5000, 30000))),
      nodesize = as.integer(round(runif(hp_samples, 1, 20))),
      sampsize0 = as.integer(round(runif(hp_samples, 50, 3000)))
    )
  } else if (spec=="quad") {
    hp_grid <- tibble(
      tune_id  = 1:hp_samples,
      mtry     = as.integer(round(runif(hp_samples, 2, 5))),
      ntree    = as.integer(round(runif(hp_samples, 5000, 30000))),
      nodesize = as.integer(round(runif(hp_samples, 1, 20))),
      sampsize0 = as.integer(round(runif(hp_samples, 50, 3000)))
    )
  } else if (spec=="goldstein") {
    hp_grid <- tibble(
      tune_id  = 1:hp_samples,
      mtry     = as.integer(round(runif(hp_samples, 1, 4))),
      ntree    = as.integer(round(runif(hp_samples, 5000, 30000))),
      nodesize = as.integer(round(runif(hp_samples, 1, 20))),
      sampsize0 = as.integer(round(runif(hp_samples, 50, 3000)))
    )
  } else {
    hp_grid <- tibble(
      tune_id  = 1:hp_samples,
      mtry     = as.integer(round(runif(hp_samples, 10, 45))),
      ntree    = as.integer(round(runif(hp_samples, 5000, 30000))),
      nodesize = as.integer(round(runif(hp_samples, 1, 20))),
      sampsize0 = as.integer(round(runif(hp_samples, 50, 3000)))
    )
  }
} else {
  # 6-months horizon
  if (spec=="escalation") {
    hp_grid <- tibble(
      tune_id  = 1:hp_samples,
      mtry     = as.integer(round(runif(hp_samples, 2, 5))),
      ntree    = as.integer(round(runif(hp_samples, 5000, 40000))),
      nodesize = as.integer(round(runif(hp_samples, 1, 50))),
      sampsize0 = as.integer(round(runif(hp_samples, 50, 1000)))
    )
  } else if (spec=="quad") {
    hp_grid <- tibble(
      tune_id  = 1:hp_samples,
      mtry     = as.integer(round(runif(hp_samples, 2, 5))),
      ntree    = as.integer(round(runif(hp_samples, 5000, 40000))),
      nodesize = as.integer(round(runif(hp_samples, 1, 50))),
      sampsize0 = as.integer(round(runif(hp_samples, 50, 1000)))
    )
  } else if (spec=="goldstein") {
    hp_grid <- tibble(
      tune_id  = 1:hp_samples,
      mtry     = as.integer(round(runif(hp_samples, 1, 4))),
      ntree    = as.integer(round(runif(hp_samples, 5000, 40000))),
      nodesize = as.integer(round(runif(hp_samples, 1, 50))),
      sampsize0 = as.integer(round(runif(hp_samples, 50, 1000)))
    )
  } else {
    hp_grid <- tibble(
      tune_id  = 1:hp_samples,
      mtry     = as.integer(round(runif(hp_samples, 10, 45))),
      ntree    = as.integer(round(runif(hp_samples, 5000, 40000))),
      nodesize = as.integer(round(runif(hp_samples, 1, 50))),
      sampsize0 = as.integer(round(runif(hp_samples, 50, 1000)))
    )
  }
}



folds <- vfold_cv(train_df, v = 2, repeats = 7*2) %>%
  # rsample creates copies of the data, so this object ends up being very big
  # this causes memory problems when running in parallel; keep the row indices
  # for train/test only instead.
  mutate(train_idx = map(splits, function(x) x$in_id),
         test_idx  = map(splits, function(x) (1:nrow(x$data))[-x$in_id]),
         splits = NULL)
# Make sure all splits have at least one positive case, otherwise ROC doesn't
# work
pos <- map_dbl(1:nrow(folds), df = train_df, function(i, df) {
  test_idx <- folds[i, ][["test_idx"]][[1]]
  sum(train_df[test_idx, ][["incidence_civil_ns_plus1"]]=="1")
})
stopifnot(all(pos > 0))

model_grid <- crossing(hp_grid, folds)

# permute the model grid so workers get a more even task load
model_grid <- model_grid[sample(1:nrow(model_grid)), ]

# expected run-time
time_model <- read_rds("output/runtime-model.rds")
et <- sum(exp(predict(time_model, cbind(ncol = length(get(spec)), machine = machine, horizon = horizon, model_grid))))/3600/(WORKERS*.9)
lgr$info("Expected runtime with %s workers: %s hours", WORKERS, round(et, 1))

# Some of the models can take a long time to run. Chunk the output and write
# it to files so that one can at least have some sense of progress.
dir.create("output/chunks", showWarnings = FALSE)
writeLines(as.character(nrow(model_grid)), "output/chunks/n-chunks.txt")

res <- foreach(i = 1:nrow(model_grid),
               .export = c("model_grid", "train_df", "spec", "cameo",
                           "escalation", "quad", "goldstein", "machine",
                           "horizon"),
               .packages = c("randomForest", "tibble", "yardstick", "dplyr"),
               .inorder = FALSE) %dopar% {

  # keep track of run time
  t0 <- proc.time()

  res_i <- tryCatch({
    train_i <- train_df[model_grid$train_idx[[i]], ]
    test_i  <- train_df[model_grid$test_idx[[i]], ]

    fitted_mdl <- randomForest(y = train_i$incidence_civil_ns_plus1,
                               x = train_i[, get(spec)],
                               type = "classification",
                               ntree = model_grid$ntree[[i]],
                               mtry  = model_grid[i, ][["mtry"]],
                               nodesize = model_grid[i, ][["nodesize"]],
                               strata = train_i$incidence_civil_ns_plus1,
                               sampsize = c(1, model_grid[i, ][["sampsize0"]]),
                               replace = FALSE,
                               do.trace = FALSE)

    test_preds <- tibble(
      preds = as.vector(predict(fitted_mdl, newdata = test_i[, get(spec)], type = "prob")[, "1"]),
      truth = test_i[, dv])
    res_i <- tibble(
      i = i,
      horizon = horizon,
      spec = spec,
      tune_id = model_grid[i, ][["tune_id"]],
      ntree = model_grid[i, ][["ntree"]],
      mtry  = model_grid[i, ][["mtry"]],
      nodesize = model_grid[i, ][["nodesize"]],
      sampsize0 = model_grid[i, ][["sampsize0"]],
      AUC = roc_auc(test_preds, truth, preds)[[".estimate"]],
      time = (proc.time() - t0)["elapsed"],
      machine = machine
    )

    write_csv(res_i, path = sprintf("output/chunks/chunk-%s.csv", i))

    res_i
  }, error = function(e) {
    res_i <- tibble(
      i = i,
      horizon = horizon,
      spec = spec,
      tune_id = model_grid[i, ][["tune_id"]],
      ntree = model_grid[i, ][["ntree"]],
      mtry  = model_grid[i, ][["mtry"]],
      nodesize = model_grid[i, ][["nodesize"]],
      sampsize0 = model_grid[i, ][["sampsize0"]],
      AUC = NA_real_,
      time = (proc.time() - t0)["elapsed"],
      machine = machine
    )

    write_csv(res_i, path = sprintf("output/chunks/chunk-%s.csv", i))

    res_i
  })

  NULL
}

res <- dir("output/chunks", patter = ".csv", full.names = TRUE) %>%
  purrr::map(read_csv, col_types = cols(
    i = col_double(),
    horizon = col_character(),
    spec = col_character(),
    tune_id = col_double(),
    ntree = col_double(),
    mtry = col_double(),
    nodesize = col_double(),
    sampsize0 = col_double(),
    AUC = col_double(),
    time = col_double(),
    machine = col_character()
  )) %>%
  bind_rows()

path <- file.path("output/batches", tune_res_filename)
write_rds(res, path)

# clean up / remove the chunks
unlink("output/chunks", recursive = TRUE)

tt <- (proc.time() - t0)["elapsed"]
lgr$info("Tuning script finished (%.02fh vs %.02fh expected)",
         as.integer(tt)/3600, et)

warnings()
