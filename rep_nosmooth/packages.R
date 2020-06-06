#
#   Check for needed packages
#

check_packages <- function() {
  installed <- rownames(installed.packages())

  need <- c("dplyr", "readr", "randomForest", "yaml", "jsonlite", "pROC",
            "foreach", "doFuture", "doRNG", "lgr", "tidyr", "ggplot2", "stringr",
            "rsample", "readstata13", "here")

  not_installed <- need[!need %in% installed]

  if ("dplyr" %in% installed) {
    # need v 1.0.0 or greater in order to be able to group_by a list column in
    # recreate-tables.R
    vv <- packageVersion("dplyr")
    if (vv < "1.0.0") {
      message(sprintf("dplyr >= 1.0.0 is required; found %s; adding to install list", vv))
      not_installed <- c("dplyr", not_installed)
    }
  }

  if (length(not_installed) > 0) {
    message("Some packages need to be installed or updated. Please run:\n",
            sprintf("  install.packages(c(%s))",
                    paste0(sprintf("\"%s\"", not_installed), collapse = ", ")),
            "\nand then re-run this script.")
    stop("Not all required packages are installed.")
  }

  message("All required packages are installed")
  invisible(TRUE)
}

check_packages()
