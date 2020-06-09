#
#   Count chunk files in order to monitor tune experiment progress
#

library(here)

suppressMessages(setwd(here::here("table1-redo")))

n_chunks <- as.integer(readLines("output/chunks/n-chunks.txt"))

done <- length(dir("output/chunks/prediction", pattern = "brf"))
cat(sprintf("%s of %s chunks done\n", done, n_chunks))
cat(sprintf("%s%% complete", round(done/n_chunks*100, 0)))
