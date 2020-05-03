#
#   Count chunk files in order to monitor tune experiment progress
#

library(here)

setwd(here::here("tuning-experiments"))

n_chunks <- as.integer(readLines("output/chunks/n-chunks.txt"))

done <- length(dir("output/chunks")) - 1L
cat(sprintf("%s of %s chunks done", done, n_chunks))
cat(sprintf("%s%% complete", round(done/n_chunks*100, 0)))
