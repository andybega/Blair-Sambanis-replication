#
#   Cleaning up the tuning results. I switched to saving each batch file
#   explicitly, whereas previously I added it all to tune-results-cumulative.
#   Take results that are in the batch files out of tune-results-cumulative.
#

batches <- dir("output/batches", full.names = TRUE) %>%
  map(., read_rds) %>%
  bind_rows(.id = "file_id") %>%
  mutate(source = "batches")

# Are Rick's results coded as a batch file already?
rick <- read_rds("output/tune-results-Rick.rds") %>%
  mutate(source = "Rick")

table(batches$machine)

# Easy, make it a batch file.

file.copy("output/tune-results-Rick.rds", "output/batches")
file.rename("output/batches/tune-results-Rick.rds", "output/batches/1-month-cameo-4.rds")

old_tunes <- read_rds("output/tune-results-cumulative.rds") %>%
  mutate(source = "old tune")

check <- batches %>%
  select(i, spec, tune_id, ntree, mtry, nodesize, sampsize0, machine, horizon)

old_tunes_in_batch <- semi_join(old_tunes, check)
table(old_tunes_in_batch$tune_batch_id)

old_tunes_not_in_batch <- anti_join(old_tunes, check)
table(old_tunes_not_in_batch$tune_batch_id)

# the 25 batch ID is odd here
old_tunes %>%
  filter(tune_batch_id==25) %>%
  count(machine)

# Wups, that's the samples from Rick that I made a new batch file out of above
# confirm
all(unique(rick$ntree) %in% unique(old_tunes[old_tunes$tune_batch_id==25, ]$ntree))

# ok, so batch 21 and before need to remain
fixed_old_tunes <- old_tunes %>%
  filter(tune_batch_id <= 21)

write_rds(fixed_old_tunes, "output/batches/older-tune-results.rds")


