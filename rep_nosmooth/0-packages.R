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

  # special treatment for randomForest (#12)
  if ("randomForest" %in% not_installed) {
    message("Please install version 4.6-14 of randomForest from source:\n\n",
            "devtools::install_version(\"randomForest\", version = \"4.6-14\")",
            "\n\nSee https://github.com/andybega/Blair-Sambanis-replication/issues/12 for more details.\n")
  } else {
    # make sure correct version of randomForest is at hand
    ver <- installed.packages()["randomForest", "Version"]
    if (ver > "4.6-14") {
      message("Due to a memory issue with the latest version of {randomForest} on CRAN, ",
              "an older version of the package is needed.\n",
              "See https://github.com/andybega/Blair-Sambanis-replication/issues/12 for more details.\n\n",
              "devtools::install_version(\"randomForest\", version = \"4.6-14\")")
      return(invisible(FALSE))
    }
  }

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
