

data_6month_oos <- read.dta13("data/6mo_data_OOS.dta")

data_6month_oos %>% count(incidence_civil_ns_plus1)
data_6month_oos %>% count(incidence_civil_ns )

# this object contains OOS forecasts from 2008 to 2016
as_tibble(pred_escalation_6mo_inc_civil_ns)

fcast2016 <- pred_escalation_6mo_inc_civil_ns %>%
  filter(year==2016)

fcast2016 %>% count(incidence_civil_ns_plus1)
fcast2016 %>% count(incidence_civil_ns )

fcast2016 %>%
  filter(is.na(incidence_civil_ns)) %>%
  dplyr::select(year, country)

# Ok, indeed it looks like "incidence_civil_ns" was originally incidence and
# then recoded to onset, with NA for continuing conflicts
data_6month_oos %>%
  ggplot(aes(x = year, y = factor(country_iso3), fill = factor(incidence_civil_ns))) +
  geom_tile()

# How does this look in the full data?
data_6month <- read.dta13("data/6mo_data_OOS.dta")
data_6month %>%
  ggplot(aes(x = year, y = factor(country_iso3), fill = factor(incidence_civil_ns))) +
  geom_tile()

data_6month %>%
  ggplot(aes(x = year, y = factor(country_iso3), fill = factor(incidence_civil_ns_plus1))) +
  geom_tile()

# What's going on with the positive cases here?
dv <- data_6month %>%
  filter(incidence_civil_ns==1) %>%
  dplyr::select(country_name, country_iso3, year, period, incidence_civil_ns)
dv_plus1 <- data_6month %>%
  filter(incidence_civil_ns_plus1==1) %>%
  dplyr::select(country_name, country_iso3, year, period, incidence_civil_ns_plus1)
both_dvs <- full_join(dv_plus1, dv) %>%
  arrange(country_name, year)

ggplot(data_6month, aes(x = period, y = factor(country_iso3),
                        fill = factor(incidence_civil_ns_plus1))) +
  geom_tile()



# Predictions
preds <- read.dta13("data/6mo_predictions_escalation_OOS.dta") %>%
  as_tibble() %>%
  filter(period==max(period)) %>%
  mutate(incidence_civil_ns = as.integer(incidence_civil_ns),
         incidence_civil_ns_plus1 = as.integer(incidence_civil_ns_plus1))



# Hand-code the Table 3 predictions;
# The predictions don't exactly match what is in Table 3, possibley because I
# only ran the 6 month OOS portion of +master.R after setting the seed at the
# top.
pred1 <- c("Nigeria", "India", "Iraq", "Somalia", "Syria", "Pakistan",
           "Philippines", "Turkey", "Afghanistan", "Russia", "Burundi", "Egypt",
           "Yemen", "Colombia", "Mali", "China", "Indonesia", "Ukraine",
           "Sudan", "Lebanon", "Thailand", "Iran", "Myanmar", "Montenegro",
           "Bangladesh", "Niger", "El Salvador", "France", "Ghana", "Tajikistan")
codes <- countrycode::countrycode(pred1, "country.name", "iso3c")
preds$label <- as.integer(preds$country %in% codes)
# should be 30
sum(preds$label)

# What is the truth data in preds?
preds %>% count(incidence_civil_ns)
preds %>% count(incidence_civil_ns_plus1)

# Does this match the OOS data?
data_6month_oos %>% filter(period==31) %>% count(incidence_civil_ns)
data_6month_oos %>% filter(period==31) %>% count(incidence_civil_ns_alt1_plus1)

tab4_top <- preds %>%
  rename(Observed = incidence_civil_ns, Predicted = label) %>%
  replace_na(list(Observed = 0L)) %>%
  mutate(Observed = factor(Observed, levels = c("0", "1")),
         Predicted = factor(Predicted, levels = c("0", "1"))) %>%
  group_by(Observed, Predicted) %>%
  dplyr::summarize(n = n()) %>%
  ungroup() %>%
  tidyr::complete(Observed, Predicted, fill = list(n = 0)) %>%
  mutate(header = "Assuming Persistence")

# From 6mo_make_confusion_matrix.do, for the bottom of Table 3:
# replace incidence_civil_ns_alt=0 if country_name=="Colombia"
# replace incidence_civil_ns_alt=1 if country_name=="Turkey"
# replace incidence_civil_ns_alt=1 if country_name=="Burundi"
preds %>%
  filter(country %in% c("COL", "TUR", "BDI"))

data_6month_oos %>%
  filter(country_iso3 %in% c("COL", "TUR", "BDI")) %>%
  dplyr::select(country_iso3, year, incidence_civil_ns, incidence_civil_ns_plus1)

# Burundi has no ongoing conflict, so this is new onset
# Colombia has ongong conflict, so no difference
# Turkey has no ongoing conflict, so this is new onset
preds_v2 <- preds %>%
  mutate(incidence_civil_ns = case_when(
    country=="TUR" ~ 1L,
    country=="BDI" ~ 1L,
    TRUE ~ incidence_civil_ns
  ))

tab4_bottom <- preds_v2 %>%
  rename(Observed = incidence_civil_ns, Predicted = label) %>%
  replace_na(list(Observed = 0L)) %>%
  mutate(Observed = factor(Observed, levels = c("0", "1")),
         Predicted = factor(Predicted, levels = c("0", "1"))) %>%
  group_by(Observed, Predicted) %>%
  dplyr::summarize(n = n()) %>%
  ungroup() %>%
  tidyr::complete(Observed, Predicted, fill = list(n = 0)) %>%
  mutate(header = "Assuming Change")

tab4 <- bind_rows(tab4_top, tab4_bottom) %>%
  dplyr::select(header, everything()) %>%
  pivot_wider(names_from = "Predicted", values_from = n)

write_csv(tab4, "data/tab4-fixed.csv")

