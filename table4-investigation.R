

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
data_6month <- read.dta13("data/6mo_data.dta")
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


