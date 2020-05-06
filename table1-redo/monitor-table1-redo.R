#
#   Count chunk files in order to monitor tune experiment progress
#

library(here)

suppressMessages(setwd(here::here("tuning-experiments")))

n_chunks <- as.integer(readLines("output/table1-chunks/n-chunks.txt"))

done <- length(dir("output/table1-chunks/prediction"))
cat(sprintf("%s of %s chunks done\n", done, n_chunks))
cat(sprintf("%s%% complete", round(done/n_chunks*100, 0)))
