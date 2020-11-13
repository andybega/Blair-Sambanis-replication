#
#   Replication master script
#

# The scripts use the here package to set working directories. The root
# directory should be the Blair-Sambanis-replication folder, and this should
# work out of the box if you cloned the whole repo.
# Otherwise, read ?here for how to get here to recognize the correct root
# directory.
#
# NB: in 2-model-runner.R, check and adjust WORKERS on line 7
#

# Make sure required packages are installed
source("0-packages.R")

# Encode original B&S Tables 1 and 2
source("1-make-original-tables.R")

# Re-save data from Stata to R formats for faster loading
source("1-re-save-data.R")

# Create model table that we will use for running models in parallel
source("1-setup-model-table.R")

# Run models (this should take about 1 hour)
# NB: check and adjust WORKERS on line 7 before running this
source("2-model-runner.R")

# Recreate Tables 1 and 2 from new output
source("3-recreate-tables.R")

# Figures
source("4-make-figure1.R")
source("4-make-figure2.R")
source("4-make-figureA1.R")
source("4-make-figureA2.R")
source("4-make-figureA3.R")


