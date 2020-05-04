#
#   Recreate table 1 with non-smoothed ROC
#
# install.packages("")
library(readr)
library(kableExtra)
library(knitr)
library(dplyr)
library(here)

setwd(here::here("Replication files/replication-3_BM"))


# Write table summaries for monitoring on git

auc <- lapply(dir("tables", pattern = "auc-", full.names = TRUE), read_csv,
              col_types = cols(
                model = col_character(),
                specification = col_character(),
                horizon = col_character(),
                smoothed = col_double(),
                original = col_double()
              )) %>%
  bind_rows() %>%
  dplyr::select(model, horizon, specification, smoothed, original)

write_csv(auc, "tables/table1-redone.csv")
write_csv(auc, "../../data/table1-redone.csv")

# Write latex versions of table 1

top <- read_csv("tables/table1_top.csv") %>%
  rename(`ROC Smoothed` = X1) %>%
  mutate(Horizon = "1 Month",
         model = "Base Specification",
         `ROC Smoothed` = case_when(`ROC Smoothed` == "Smoothed" ~ "Yes",
                                    `ROC Smoothed` == "Not Smoothed" ~ "No")) %>%
  select(model, Horizon, everything())

bottom <- read_csv("tables/table1_bottom.csv") %>%
  rename(`ROC Smoothed` = X1) %>%
  mutate(Horizon = "6 Months",
         model = "Base Specification",
         `ROC Smoothed` = case_when(`ROC Smoothed` == "Smoothed" ~ "Yes",
                                    `ROC Smoothed` == "Not Smoothed" ~ "No")) %>%
  select(model, Horizon, everything())

tab_dat <- bind_rows(top, bottom)
names(tab_dat) <- c("Model", "Horizon", "ROC Smoothed", "Escalation", "Quad", "Goldstein", "CAMEO", "Avg")

footnote_text <- 'To create Table 1, Blair and Sambanis use a non-standard "smoothing" function when creating their various Receiver Operating Characteristic Curves (ROC). These "smoothed" curves are then used to compute their model performance metric -- the Area Under the Receiver Operating Characteristic Curve (AUC-ROC). We recreate these AUC-ROC scores with and without the smoothing function (Blair and Sambanis\' specification and the standard specification, respectively). This allows us to see if their findings are sensitive to the use of the smoothing function.'

knitr::kable(tab_dat, "latex", booktabs = TRUE, linesep = "\\addlinespace", digits = c(3),
             label = "tab-1", caption = "", align = c(rep("l", 3), rep("c", 5))) %>%
  column_spec(c(3), bold = TRUE) %>%
  collapse_rows(1:2, row_group_label_position = 'stack') %>%
  add_footnote(label = footnote_text, notation = "none", threeparttable = TRUE) %>%
# writeLines(., "tables/replicated-table-1.tex")
writeLines(., "../../data/replicated-table-1.tex")

# auc <- lapply(dir("tables", pattern = "auc-", full.names = TRUE), read_csv,
#               col_types = cols(
#                 model = col_character(),
#                 specification = col_character(),
#                 horizon = col_character(),
#                 smoothed = col_double(),
#                 original = col_double()
#               )) %>%
#   bind_rows() %>%
#   select(horizon, model, specification, smoothed, original)

