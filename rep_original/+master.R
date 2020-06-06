# Setup ------------------------------------------------------------

set.seed(92382)

# Clear environment

rm(list = ls())

# Set working directory

# CHANGE: use here() for relative path
setwd(here::here("rep_original"))

# CHANGE: wrapper for ROCR::prediction() that handles NA's
port <- list(
  prediction = function(predictions, labels, ...) {
    stopifnot(length(predictions)==length(labels))
    not_na <- !is.na(predictions) & !is.na(labels)
    ROCR::prediction(predictions[not_na], labels[not_na], ...)
  }
)

# Load packages

library(foreign)
library(separationplot)
library(dyn)
library(gdata)
library(ROCR)
library(readstata13)
library(verification)
library(WriteXLS)
library(randomForest)
library(scales)
library(pROC)
library(extrafont)
library(fontcm)
library(corpcor)
library(ggplot2)
library(fontcm)
library(PRROC)
library(Bolstad2)
# CHANGE: add logging to monitor progress
library(lgr)

# Specify length of ROC curve

test_observations <- 10000



# Define 1-month models ------------------------------------------------------------

# Load data

data <- read.dta13("data/1mo_data.dta")

# Define training and testing sets for base specification

train_period = mean(data$period[which(data$month==12 & data$year==2007)])
end_period = mean(data$period[which(data$month==12 & data$year==2015)])
train <- data[data$period<=train_period,]
test <- data[data$period>train_period & data$period<=end_period,]

# Define training and testing sets for robustness checks using alternate start dates

train_period_robust_traintest1 = mean(data$period[which(data$month==12 & data$year==2008)])
end_period = mean(data$period[which(data$month==12 & data$year==2015)])
train_robust_traintest1 <- data[data$period<=train_period_robust_traintest1,]
test_robust_traintest1 <- data[data$period>train_period_robust_traintest1 & data$period<=end_period,]

train_period_robust_traintest2 = mean(data$period[which(data$month==12 & data$year==2009)])
end_period = mean(data$period[which(data$month==12 & data$year==2015)])
train_robust_traintest2 <- data[data$period<=train_period_robust_traintest2,]
test_robust_traintest2 <- data[data$period>train_period_robust_traintest2 & data$period<=end_period,]

train_period_robust_traintest3 = mean(data$period[which(data$month==12 & data$year==2010)])
end_period = mean(data$period[which(data$month==12 & data$year==2015)])
train_robust_traintest3 <- data[data$period<=train_period_robust_traintest3,]
test_robust_traintest3 <- data[data$period>train_period_robust_traintest3 & data$period<=end_period,]

# Define training and test sets for PITF split population model

country_mean_pred_prob <- aggregate(pred_prob~country_iso3, train, mean)
overall_mean_pred_prob <- mean(country_mean_pred_prob$pred_prob)
overall_bottom25_pred_prob <- quantile(country_mean_pred_prob$pred_prob, c(.25))

lowrisk_threshold <- (country_mean_pred_prob$pred_prob<overall_bottom25_pred_prob)
lowrisk_matrix <- cbind(country_mean_pred_prob, lowrisk_threshold)
highrisk_threshold <- (country_mean_pred_prob$pred_prob>=overall_bottom25_pred_prob)
highrisk_matrix <- cbind(country_mean_pred_prob, highrisk_threshold)

train_highrisk <- merge(train, highrisk_matrix, by="country_iso3")
train_highrisk <- train_highrisk[which(train_highrisk$highrisk_threshold==TRUE),]
test_highrisk <- merge(test, highrisk_matrix, by="country_iso3")
test_highrisk <- test_highrisk[which(test_highrisk$highrisk_threshold==TRUE),]

train_lowrisk <- merge(train, lowrisk_matrix, by="country_iso3")
train_lowrisk <- train_lowrisk[which(train_lowrisk$lowrisk_threshold==TRUE),]
test_lowrisk <- merge(test, lowrisk_matrix, by="country_iso3")
test_lowrisk <- test_lowrisk[which(test_lowrisk$lowrisk_threshold==TRUE),]

# Define predictand for base specification

train_DV_civil_ns <- train$incidence_civil_ns_plus1
test_DV_civil_ns <- test$incidence_civil_ns_plus1

# Define predictand for robustness checks using alternate start dates

train_DV_civil_ns_robust_traintest1 <- train_robust_traintest1$incidence_civil_ns_plus1
test_DV_civil_ns_robust_traintest1 <- test_robust_traintest1$incidence_civil_ns_plus1

train_DV_civil_ns_robust_traintest2 <- train_robust_traintest2$incidence_civil_ns_plus1
test_DV_civil_ns_robust_traintest2 <- test_robust_traintest2$incidence_civil_ns_plus1

train_DV_civil_ns_robust_traintest3 <- train_robust_traintest3$incidence_civil_ns_plus1
test_DV_civil_ns_robust_traintest3 <- test_robust_traintest3$incidence_civil_ns_plus1

# Define predictand for robustness checks using alternate coding of civil war

train_DV_civil_ns_alt1 <- train$incidence_civil_ns_alt1_plus1
test_DV_civil_ns_alt1 <- test$incidence_civil_ns_alt1_plus1

train_DV_civil_ns_alt2 <- train$incidence_civil_ns_alt2_plus1
test_DV_civil_ns_alt2 <- test$incidence_civil_ns_alt2_plus1

# Define predictand for PITF split population model

train_DV_civil_ns_highrisk <- train_highrisk$incidence_civil_ns_plus1
test_DV_civil_ns_highrisk <- test_highrisk$incidence_civil_ns_plus1

train_DV_civil_ns_lowrisk <- train_lowrisk$incidence_civil_ns_plus1
test_DV_civil_ns_lowrisk <- test_lowrisk$incidence_civil_ns_plus1

# Define models

lgr$info("Assign 1 month model objects")
source("code/1mo_define_models.R", local = TRUE)



# Run 1-month models ------------------------------------------------------------


# Run models

lgr$info("1 month escalation models")
source("code/1mo_run_escalation.R", local = TRUE, echo = TRUE)

# CHANGE: save additional artifacts for verifying the rep_nosmooth code
saveRDS(escalation_train_formula_civil_ns, "extra/escalation_train_formula_civil_ns.rds")
saveRDS(escalation_train_frame_civil_ns, "extra/escalation_train_frame_civil_ns.rds")
saveRDS(train_model, "extra/train_model.rds")
saveRDS(escalation_test_frame_civil_ns, "extra/escalation_test_frame_civil_ns.rds")
saveRDS(test_DV_civil_ns, "extra/test_DV_civil_ns.rds")

lgr$info("1 month quad models")
source("code/1mo_run_quad.R", local = TRUE)

lgr$info("1 month goldstein models")
source("code/1mo_run_goldstein.R", local = TRUE)

lgr$info("1 month CAMEO models")
source("code/1mo_run_all_CAMEO.R", local = TRUE)

lgr$info("1 month average models")
source("code/1mo_run_avg.R", local = TRUE)

# Save predictions

saveRDS(pred_escalation_inc_civil_ns,"predictions/1mo_predictions_escalation.rds")

saveRDS(pred_quad_inc_civil_ns,"predictions/1mo_predictions_quad.rds")

saveRDS(pred_goldstein_inc_civil_ns,"predictions/1mo_predictions_goldstein.rds")

saveRDS(pred_all_CAMEO_inc_civil_ns,"predictions/1mo_predictions_all_CAMEO.rds")

saveRDS(pred_avg_inc_civil_ns,"predictions/1mo_predictions_avg.rds")

# Create top panel of Table 1

AUCs <- as.matrix(cbind(AUCs_escalation,AUCs_quad,AUCs_goldstein,AUCs_all_CAMEO,AUCs_avg))
colnames(AUCs) <- c("escalation","quad","Goldstein","CAMEO","avg")
rownames(AUCs) <- c("base","robust_maxnodes","robust_sampsize","robust_ntree","robust_traintest1","robust_traintest2","robust_traintest3","robust_DV1","robust_DV2")

write.csv(AUCs, file = "tables/table1_top.csv", row.names = T)

# Create left panel of Figure 1

source("code/1mo_make_ROC.R", local = TRUE)

# Create left panel of Figure 2

source("code/1mo_make_PR.R", local = TRUE)

# Create Figure 3

source("code/1mo_make_separation.R", local = TRUE)

lgr$info("1 month table 2 models")

# Run escalation model with PITF predictors

source("code/1mo_run_escalation_with_PITF.R", local = TRUE)

# Run escalation model weighted by PITF predicted probabilities

source("code/1mo_run_escalation_weighted_PITF.R", local = TRUE)

# Run split population escalation model using PITF predicted probabilities

source("code/1mo_run_escalation_split_PITF.R", local = TRUE)

# Run PITF model

source("code/1mo_run_PITF.R", local = TRUE)

# Create top panel of Table 2

AUCs_escalation_PITF <- as.matrix(cbind(AUCs_escalation[1,],AUCs_escalation_with_PITF,AUCs_escalation_weighted_PITF,AUCs_escalation_split_PITF,AUCs_PITF))
colnames(AUCs_escalation_PITF) <- c("escalation","with_PITF","weighted_PITF","split_PITF","PITF")
rownames(AUCs_escalation_PITF) <- c("base")

write.csv(AUCs_escalation_PITF, file = "tables/table2_top.csv", row.names = T)

# Create top panel of Table A4

brier <- as.matrix(cbind(brier_obs_escalation_inc_civil_ns,brier_obs_quad_inc_civil_ns,brier_obs_goldstein_inc_civil_ns,brier_obs_all_CAMEO_inc_civil_ns,brier_obs_avg_inc_civil_ns))
f1 <- as.matrix(cbind(f1_max_escalation_inc_civil_ns,f1_max_quad_inc_civil_ns,f1_max_goldstein_inc_civil_ns,f1_max_all_CAMEO_inc_civil_ns,f1_max_avg_inc_civil_ns))

brier_f1 <- rbind(brier,f1)

colnames(brier_f1) <- c("escalation","quad","Goldstein","CAMEO","avg")
rownames(brier_f1) <- c("brier","f1")

write.csv(brier_f1, file = "tables/tableA4_top.csv", row.names = T)

# Run escalation model with lagged low-level violence

source("code/1mo_run_escalation_withlags.R", local = TRUE)

# Run escalation model with low-level violence only

source("code/1mo_run_escalation_simple.R", local = TRUE)

# Create top panel of Table A5

AUCs_alt <- as.matrix(cbind(AUCs_escalation_simple,AUCs_escalation_withlags))
colnames(AUCs_alt) <- c("escalation_simple","escalation_withlags")
rownames(AUCs_alt) <- c("base")

write.csv(AUCs_alt, file = "tables/tableA5_top.csv", row.names = T)

# Create left panels of Figure A11 - A14

source("code/1mo_make_importance.R", local = TRUE)

# Save workspace

check <- file.exists(file="workspaces/1mo_workspace.RData")

if(check=="FALSE") {
  save.image(file="workspaces/1mo_workspace.RData")
}

if(check=="TRUE") {
  file.remove(file="workspaces/1mo_workspace.RData")
  save.image(file="workspaces/1mo_workspace.RData")
}



# Define 6-month models ------------------------------------------------------------

lgr$info("start 6 month models")

# Clear environment

rm(list = ls())

# Load data

data <- read.dta13("data/6mo_data.rds")

# Define training and testing sets for base specification

train_period = 14
end_period = 30
train <- data[data$period<=train_period,]
test <- data[data$period>train_period & data$period<=end_period,]

# Define training and testing sets for robustness checks using alternate start dates

train_period_robust_traintest1 = 16
end_period = 30
train_robust_traintest1 <- data[data$period<=train_period_robust_traintest1,]
test_robust_traintest1 <- data[data$period>train_period_robust_traintest1 & data$period <= end_period,]

train_period_robust_traintest2 = 18
end_period = 30
train_robust_traintest2 <- data[data$period<=train_period_robust_traintest2,]
test_robust_traintest2 <- data[data$period>train_period_robust_traintest2 & data$period <= end_period,]

train_period_robust_traintest3 = 20
end_period = 30
train_robust_traintest3 <- data[data$period<=train_period_robust_traintest3,]
test_robust_traintest3 <- data[data$period>train_period_robust_traintest3 & data$period <= end_period,]

# Define training and test sets for PITF split population model

country_mean_pred_prob <- aggregate(pred_prob~country_iso3, train, mean)
overall_mean_pred_prob <- mean(country_mean_pred_prob$pred_prob)
overall_bottom25_pred_prob <- quantile(country_mean_pred_prob$pred_prob, c(.25))

lowrisk_threshold <- (country_mean_pred_prob$pred_prob<overall_bottom25_pred_prob)
lowrisk_matrix <- cbind(country_mean_pred_prob, lowrisk_threshold)
highrisk_threshold <- (country_mean_pred_prob$pred_prob>=overall_bottom25_pred_prob)
highrisk_matrix <- cbind(country_mean_pred_prob, highrisk_threshold)

train_highrisk <- merge(train, highrisk_matrix, by="country_iso3")
train_highrisk <- train_highrisk[which(train_highrisk$highrisk_threshold==TRUE),]
test_highrisk <- merge(test, highrisk_matrix, by="country_iso3")
test_highrisk <- test_highrisk[which(test_highrisk$highrisk_threshold==TRUE),]

train_lowrisk <- merge(train, lowrisk_matrix, by="country_iso3")
train_lowrisk <- train_lowrisk[which(train_lowrisk$lowrisk_threshold==TRUE),]
test_lowrisk <- merge(test, lowrisk_matrix, by="country_iso3")
test_lowrisk <- test_lowrisk[which(test_lowrisk$lowrisk_threshold==TRUE),]

# Define predictand for base specification

train_DV_civil_ns <- train$incidence_civil_ns_plus1
test_DV_civil_ns <- test$incidence_civil_ns_plus1

# Define predictand for robustness checks using alternate start dates

train_DV_civil_ns_robust_traintest1 <- train_robust_traintest1$incidence_civil_ns_plus1
test_DV_civil_ns_robust_traintest1 <- test_robust_traintest1$incidence_civil_ns_plus1

train_DV_civil_ns_robust_traintest2 <- train_robust_traintest2$incidence_civil_ns_plus1
test_DV_civil_ns_robust_traintest2 <- test_robust_traintest2$incidence_civil_ns_plus1

train_DV_civil_ns_robust_traintest3 <- train_robust_traintest3$incidence_civil_ns_plus1
test_DV_civil_ns_robust_traintest3 <- test_robust_traintest3$incidence_civil_ns_plus1

# Define predictand for robustness checks using alternate coding of civil war

train_DV_civil_ns_alt1 <- train$incidence_civil_ns_alt1_plus1
test_DV_civil_ns_alt1 <- test$incidence_civil_ns_alt1_plus1

train_DV_civil_ns_alt2 <- train$incidence_civil_ns_alt2_plus1
test_DV_civil_ns_alt2 <- test$incidence_civil_ns_alt2_plus1

# Define predictand for PITF split population model

train_DV_civil_ns_highrisk <- train_highrisk$incidence_civil_ns_plus1
test_DV_civil_ns_highrisk <- test_highrisk$incidence_civil_ns_plus1

train_DV_civil_ns_lowrisk <- train_lowrisk$incidence_civil_ns_plus1
test_DV_civil_ns_lowrisk <- test_lowrisk$incidence_civil_ns_plus1

# Define models

lgr$info("Assign 6 month model objects")
source("code/6mo_define_models.R", local = TRUE)




# Run 6-month models ------------------------------------------------------------

# Run models

lgr$info("6 month escalation models")
source("code/6mo_run_escalation.R", local = TRUE)

# CHANGE: save additional artifacts for verifying the rep_nosmooth code
saveRDS(escalation_6mo_train_formula_civil_ns, "extra/escalation_6mo_train_formula_civil_ns.rds")
saveRDS(escalation_6mo_train_frame_civil_ns, "extra/escalation_6mo_train_frame_civil_ns.rds")
saveRDS(train_model, "extra/6mo_train_model.rds")
saveRDS(escalation_test_frame_civil_ns, "extra/escalation_6mo_test_frame_civil_ns.rds")
saveRDS(test_DV_civil_ns, "extra/6mo_test_DV_civil_ns.rds")

lgr$info("6 month quad models")
source("code/6mo_run_quad.R", local = TRUE)

lgr$info("6 month goldstein models")
source("code/6mo_run_goldstein.R", local = TRUE)

lgr$info("6 month CAMEO models")
source("code/6mo_run_all_CAMEO.R", local = TRUE)

lgr$info("6 month average models")
source("code/6mo_run_avg.R", local = TRUE)

# Save predictions

saveRDS(pred_escalation_6mo_inc_civil_ns,"predictions/6mo_predictions_escalation.rds")

saveRDS(pred_quad_6mo_inc_civil_ns,"predictions/6mo_predictions_quad.rds")

saveRDS(pred_goldstein_6mo_inc_civil_ns,"predictions/6mo_predictions_goldstein.rds")

saveRDS(pred_all_CAMEO_6mo_inc_civil_ns,"predictions/6mo_predictions_all_CAMEO.rds")

saveRDS(pred_avg_6mo_inc_civil_ns,"predictions/6mo_predictions_avg.rds")

# Create bottom panel of Table 1

AUCs_6mo <- as.matrix(cbind(AUCs_escalation_6mo,AUCs_quad_6mo,AUCs_goldstein_6mo,AUCs_all_CAMEO_6mo,AUCs_avg_6mo))
colnames(AUCs_6mo) <- c("escalation","quad","Goldstein","CAMEO","avg")
rownames(AUCs_6mo) <- c("base","robust_maxnodes","robust_sampsize","robust_ntree","robust_traintest1","robust_traintest2","robust_traintest3","robust_DV1","robust_DV2")

write.csv(AUCs_6mo, file = "tables/table1_bottom.csv", row.names = T)

# Create right panel of Figure 1

source("code/6mo_make_ROC.R", local = TRUE)

# Create right panel of Figure 2

source("code/6mo_make_PR.R", local = TRUE)

# Create Figure 4

source("code/6mo_make_separation.R", local = TRUE)

lgr$info("6 month table 2 models")

# Run escalation model with PITF predictors

source("code/6mo_run_escalation_with_PITF.R", local = TRUE)

# Run escalation model weighted by PITF predicted probabilities

source("code/6mo_run_escalation_weighted_PITF.R", local = TRUE)

# Run split population escalation model using PITF predicted probabilities

source("code/6mo_run_escalation_split_PITF.R", local = TRUE)

# Run PITF model

source("code/6mo_run_PITF.R", local = TRUE)

# Create top panel of Table 2

AUCs_escalation_6mo_PITF <- as.matrix(cbind(AUCs_escalation_6mo[1,],AUCs_escalation_6mo_with_PITF,AUCs_escalation_6mo_weighted_PITF,AUCs_escalation_6mo_split_PITF,AUCs_PITF_6mo))
colnames(AUCs_escalation_6mo_PITF) <- c("escalation","with_PITF","weighted_PITF","split_PITF","PITF")
rownames(AUCs_escalation_6mo_PITF) <- c("base")

write.csv(AUCs_escalation_6mo_PITF, file = "tables/table2_bottom.csv", row.names = T)

# Create bottom panel of Table A4

brier_6mo <- as.matrix(cbind(brier_obs_escalation_6mo_inc_civil_ns,brier_obs_quad_6mo_inc_civil_ns,brier_obs_goldstein_6mo_inc_civil_ns,brier_obs_all_CAMEO_6mo_inc_civil_ns,brier_obs_avg_6mo_inc_civil_ns))
f1_6mo <- as.matrix(cbind(f1_max_escalation_6mo_inc_civil_ns,f1_max_quad_6mo_inc_civil_ns,f1_max_goldstein_6mo_inc_civil_ns,f1_max_all_CAMEO_6mo_inc_civil_ns,f1_max_avg_6mo_inc_civil_ns))

brier_f1_6mo <- rbind(brier_6mo,f1_6mo)

colnames(brier_f1_6mo) <- c("escalation","quad","Goldstein","CAMEO","avg")
rownames(brier_f1_6mo) <- c("brier","f1")

write.csv(brier_f1_6mo, file = "tables/tableA4_bottom.csv", row.names = T)

# Run escalation model with lagged low-level violence

source("code/6mo_run_escalation_withlags.R", local = TRUE)

# Run escalation model with low-level violence only

source("code/6mo_run_escalation_simple.R", local = TRUE)

# Create botton panel of Table A5

AUCs_alt_6mo <- as.matrix(cbind(AUCs_escalation_6mo_simple,AUCs_escalation_6mo_withlags))
colnames(AUCs_alt_6mo) <- c("escalation_simple","escalation_withlags")
rownames(AUCs_alt_6mo) <- c("base")

write.csv(AUCs_alt_6mo, file = "tables/tableA5_bottom.csv", row.names = T)

# Create right panels of Figure A11 - A14

source("code/6mo_make_importance.R", local = TRUE)

# Save workspace

check <- file.exists(file="workspaces/6mo_workspace.RData")

if(check=="FALSE") {
  save.image(file="workspaces/6mo_workspace.RData")
}

if(check=="TRUE") {
  file.remove(file="workspaces/6mo_workspace.RData")
  save.image(file="workspaces/6mo_workspace.RData")
}




# Define 6-month model for out-of-sample test ------------------------------------------------------------

lgr$info("Create 2016-H1 forecasts")

# Clear environment

rm(list = ls())

# Load data

data <- read.dta13("data/6mo_data_OOS.dta")

# Define training and testing sets for base specification

train_period = 14
end_period = 31
train <- data[data$period<=train_period,]
test <- data[data$period>train_period & data$period<=end_period,]

# Define predictand for base specification

train_DV_civil_ns <- train$incidence_civil_ns_plus1
test_DV_civil_ns <- test$incidence_civil_ns_plus1

# Define models

source("code/6mo_define_models_OOS.R", local = TRUE)

# Run random forest model

source("code/6mo_run_escalation_OOS.R", local = TRUE)

# Save predictions

saveRDS(pred_escalation_6mo_inc_civil_ns,"predictions/6mo_predictions_escalation_OOS.rds")

# Save workspace

check <- file.exists(file="workspaces/6mo_OOS_workspace.RData")

if(check=="FALSE") {
  save.image(file="workspaces/6mo_OOS_workspace.RData")
}

if(check=="TRUE") {
  file.remove(file="workspaces/6mo_OOS_workspace.RData")
  save.image(file="workspaces/6mo_OOS_workspace.RData")
}

lgr$info("+master.R script has finished")


