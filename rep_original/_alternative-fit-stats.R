

library(yardstick)
library(stringr)

mn_brier_vec <- function(truth, pred) {
  truth <- truth==1
  mean((truth - pred)^2, na.rm = TRUE)
}

pred_files <- dir("predictions", full.names = TRUE, pattern = "[0-9]{1}mo")
pred_files <- pred_files[!str_detect(pred_files, "OOS")]

res <- tibble(model = basename(pred_files), pred_files = pred_files) %>%
  mutate(
    data = map(pred_files, function(x) {
      df <- read.dta13(x)
      df$prediction = suppressWarnings(as.numeric(df$prediction))
      df$incidence_civil_ns_plus1 = factor(df$incidence_civil_ns_plus1, levels = c("1", "0"))
      df <- df[complete.cases(df), ]
      df
    })
  ) %>%
  mutate(
    auc_roc = map_dbl(data, ~roc_auc_vec(.x$incidence_civil_ns_plus1, .x$prediction)),
    auc_pr  = map_dbl(data, ~pr_auc_vec(.x$incidence_civil_ns_plus1, .x$prediction)),
    avg_brier = map_dbl(data, ~mn_brier_vec(.x$incidence_civil_ns_plus1, .x$prediction)),
    mn_log_loss = map_dbl(data, ~mn_log_loss_vec(.x$incidence_civil_ns_plus1, .x$prediction))) %>%
  mutate(horizon = ifelse(str_detect(model, "1mo"), "1 month", "6 months"),
         spec = str_replace(model, "[0-9]{1}mo_predictions_([a-zA-Z_]+)\\.dta", "\\1")) %>%
  select(-pred_files, -data, -model) %>%
  select(horizon, spec, everything())

res %>%
  split(.$horizon) %>%
  lapply(., function(x) {
    df <- lapply(x, function(xx) { if (is.numeric(xx)) xx <- signif(xx, 2); as.character(xx) })
    as.data.frame(df)
  }) %>%
  bind_rows()
