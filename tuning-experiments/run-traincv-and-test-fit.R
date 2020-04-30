#
#   Run a subset of the B&S models/specifications along with modified versions
#   that use alternative RF hp settings; obtain training CV fit and test fit
#

library(tidyverse)
library(tidymodels)
library(randomForest)
library(future)
library(doFuture)
library(here)
library(lgr)

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
rf_base <- function(data, features) {

}

# Default RF
#
# RF with out of the box hyperparameter settings
rf_default <- function(data, features)

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



table(complete.cases(train_df[, escalation]))
table(complete.cases(train_df[, all_cameo]))

#
#   Training data CV ----
#   _________________

set.seed(5234)
folds <- vfold_cv(train_df, v = 2, repeats = 7*3)
map_dbl(folds$splits, function(x) {dat = testing(x); sum(dat[[dv]]=="1")})

res <- foreach(i=1:nrow(folds)) %dopar% {
  lgr$info("Iteration %s of %s", i, nrow(folds))
  res_i <- list()

  train_i <- training(folds$splits[[i]])
  test_i  <- testing(folds$splits[[i]])

  mdl_escalation_1 <- suppressWarnings({
    randomForest(y = as.integer(train_i$incidence_civil_ns_plus1=="1"),
                 x = train_i[, escalation],
                 type = "regression",
                 ntree = 100000,
                 maxnodes = 5,
                 sampsize = 100,
                 replace = FALSE,
                 do.trace = FALSE)
  })

  test_preds_1 <- tibble(
    preds = as.vector(predict(mdl_escalation_1, newdata = test_i[, escalation],
                              type = "response")),
    truth = test_i[, dv])
  res_i <- c(res_i, list(
    tibble(i = i,
           model = "1",
           AUC = roc_auc(test_preds_1, truth, preds)[[".estimate"]]
    )))

  mdl_escalation_2 <- randomForest(y = train_i$incidence_civil_ns_plus1,
                                   x = train_i[, escalation],
                                   type = "classification",
                                   ntree = 5000,
                                   mtry  = 3,
                                   replace = TRUE,
                                   do.trace = FALSE)

  test_preds_2 <- tibble(
    preds = as.vector(predict(mdl_escalation_2, newdata = test_i[, escalation], type = "prob")[, "1"]),
    truth = test_i[, dv])
  res_i <- c(res_i, list(
    tibble(i = i,
           model = "2",
           AUC = roc_auc(test_preds_2, truth, preds)[[".estimate"]]
    )))

  # # CAMEO models
  # mdl_3 <- suppressWarnings({
  #   randomForest(y = as.integer(train_i$incidence_civil_ns_plus1=="1"),
  #                x = train_i[, all_cameo],
  #                type = "regression",
  #                ntree = 100000,
  #                maxnodes = 5,
  #                sampsize = 100,
  #                replace = FALSE,
  #                do.trace = FALSE)
  # })
  #
  # test_preds_3 <- tibble(
  #   preds = as.vector(predict(mdl_3, newdata = test_i[, all_cameo],
  #                             type = "response")),
  #   truth = test_i[, dv])
  # res_i <- c(res_i, list(
  #   tibble(i = i,
  #          model = "3",
  #          AUC = roc_auc(test_preds_3, truth, preds)[[".estimate"]]
  #   )))
  #
  # mdl_4 <- randomForest(y = train_i$incidence_civil_ns_plus1,
  #                                  x = train_i[, all_cameo],
  #                                  type = "classification",
  #                                  ntree = 5000,
  #                                  mtry  = 34,
  #                                  replace = TRUE,
  #                                  do.trace = FALSE)
  #
  # test_preds_4 <- tibble(
  #   preds = as.vector(predict(mdl_4, newdata = test_i[, all_cameo], type = "prob")[, "1"]),
  #   truth = test_i[, dv])
  # res_i <- c(res_i, list(
  #   tibble(i = i,
  #          model = "4",
  #          AUC = roc_auc(test_preds_4, truth, preds)[[".estimate"]]
  #   )))


  res_i <- bind_rows(res_i)
  res_i
}

res <- bind_rows(res)

cv_fit <- res %>%
  group_by(model) %>%
  summarize(mean_AUC = mean(AUC),
            sd_AUC = sd(AUC))

tbl <- tibble(
  Model = c("Escalation, 1mo", "Modified Escalation, 1mo"),
  Avg_CV_ROC_AUC = cv_fit[["mean_AUC"]],
  SD_CV_ROC_AUC = cv_fit[["sd_AUC"]],
  Test_ROC_AUC = rep(NA, 2)
)


#
#   Run models on full training data and get test fit ----
#   _________________________________________________

# Estimate the final models on the full training data
mdl_escalation_1 <- suppressWarnings({
  randomForest(y = as.integer(train_df$incidence_civil_ns_plus1=="1"),
               x = train_df[, escalation],
               type = "regression",
               ntree = 100000,
               maxnodes = 5,
               sampsize = 100,
               replace = FALSE,
               do.trace = FALSE)
})

test_preds_1 <- tibble(
  preds = as.vector(predict(mdl_escalation_1, newdata = test_df[, escalation],
                            type = "response")),
  truth = test_df[, dv])
tbl$Test_ROC_AUC[1] <- roc_auc(test_preds_1, truth, preds)[[".estimate"]]



mdl_escalation_2 <- randomForest(y = train_df$incidence_civil_ns_plus1,
                                 x = train_df[, escalation],
                                 type = "classification",
                                 ntree = 5000,
                                 mtry  = 3,
                                 replace = TRUE,
                                 do.trace = FALSE)

test_preds_2 <- tibble(
  preds = as.vector(predict(mdl_escalation_2, newdata = test_df[, escalation], type = "prob")[, "1"]),
  truth = test_df[, dv])
tbl$Test_ROC_AUC[2] <- roc_auc(test_preds_2, truth, preds)[[".estimate"]]



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


tbl


# Difference of means test. Are the base and modified model AUC scores in the
# train CV different?
t.test(AUC ~ model, data = res)
# yep, p < 0.05 thus model 1 performs better than model 2.


# Roc curve for first escalation baseline model
roc_escalation <- roc_curve(test_preds_1, truth, preds)
autoplot(roc_escalation)

# the roc curve has a big kink because a bunch of cases have identical prediction
test_preds_1 %>% count(preds) %>% arrange(desc(n))




stop()




mdl_cameo <- randomForest(y = train$incidence_civil_ns_plus1,
                          x = train[, all_cameo],
                          type = "classification",
                          ntree = 1000,
                          replace = TRUE,
                          do.trace = FALSE)

preds_cameo <- tibble(
  preds = as.vector(predict(mdl_cameo, newdata = test[, all_cameo], type = "prob")[, "1"]),
  truth = test[, dv]
)

roc_cameo <- roc_curve(preds_cameo, truth, preds)
autoplot(roc_cameo)
roc_auc(preds_cameo, truth, preds)


