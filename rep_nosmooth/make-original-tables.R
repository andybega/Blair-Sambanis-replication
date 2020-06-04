#
#   Encode the original values reported for B&S Tables 1, 2, and 4
#

setwd(here::here("rep_nosmooth"))

table1 <- tribble(
  ~horizon, ~model, ~Escalation, ~Quad, ~Goldstein, ~CAMEO, ~Average,
  "1 month", "Base specification",   .85, .80, .79, .82, .82,
  "1 month", "Terminal nodes",       .85, .80, .78, .83, .82,
  "1 month", "Sample size",          .85, .81, .71, .86, .84,
  "1 month", "Trees per forest",     .85, .80, .78, .83, .82,
  "1 month", "Training/test sets 1", .86, .78, .76, .81, .80,
  "1 month", "Training/test sets 2", .81, .79, .73, .77, .78,
  "1 month", "Training/test sets 3", .79, .81, .69, .75, .76,
  "1 month", "Coding of DV 1",       .86, .81, .79, .84, .83,
  "1 month", "Coding of DV 2",       .92, .80, .81, .81, .81,
  "6 months", "Base specification",   .82, .78, .82, .76, .79,
  "6 months", "Terminal nodes",       .80, .76, .81, .76, .78,
  "6 months", "Sample size",          .83, .78, .78, .79, .79,
  "6 months", "Trees per forest",     .82, .78, .82, .77, .79,
  "6 months", "Training/test sets 1", .79, .78, .81, .76, .78,
  "6 months", "Training/test sets 2", .73, .73, .76, .73, .75,
  "6 months", "Training/test sets 3", .88, .71, .81, .68, .79,
  "6 months", "Coding of DV 1",       .83, .78, .82, .78, .80,
  "6 months", "Coding of DV 2",       .83, .77, .83, .78, .79
)

table2 <- tribble(
  ~horizon, ~`Escalation Only`, ~`With PITF Predictors`, ~`Weighted by PITF`,
  ~`PITF Split Population`, ~`PITF Only`,
  "1 month",  .85, .78, .53, .84, .76,
  "6 months", .82, .86, .52, .83, .74
)

table4 <- tribble(
  ~type, ~Observed, ~Predicted0, ~Predicted1,
  "Assuming Persistence", 0L, 132L, 17L,
  "Assuming Persistence", 1L, 2L,   13L,
  "Assuming Change", 0L, 132L, 16L,
  "Assuming Change", 1L, 2L, 14L
)

write_csv(table1, "output/tables/table1-original.csv")
write_csv(table2, "output/tables/table2-original.csv")
write_csv(table4, "output/tables/table4-original.csv")

