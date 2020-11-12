#
#   Check for needed packages
#

check_packages <- function() {
  installed <- rownames(installed.packages())

  need <- c("doFuture", "doRNG", "dplyr", "forcats", "foreach", "ggplot2",
            "here", "jsonlite", "kableExtra", "knitr", "lgr", "pROC", "purrr",
            "randomForest", "readr", "readstata13", "rsample", "stringr",
            "tibble", "tidyr", "tidyverse", "yaml", "yardstick")

  not_installed <- need[!need %in% installed]

  if ("dplyr" %in% installed) {
    # need v 1.0.0 or greater in order to be able to group_by a list column in
    # 3-recreate-tables.R
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
    return(invisible(FALSE))
  }

  message("All required packages are installed")
  invisible(TRUE)
}

check_packages()
