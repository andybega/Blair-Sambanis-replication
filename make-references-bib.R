#
#   Create the local references.bib file from the private central bib file
#

setwd(here::here("./"))

remotes::install_github("andybega/condensebib")
library(condensebib)

res <- reduce_bib(
  file = "paper.Rmd",
  master_bib = "../../whistle/master.bib",
  out_bib    = "references.bib"
)

# Change \aa to \r{a}
bib <- readLines("references.bib")
bib <- stringr::str_replace_all(bib, "\\\\aa", "\\\\r\\{a\\}")
writeLines(bib, "references.bib")


# If some references are not showing, check if RefManageR complains about them
if (FALSE) {
  msgs <- capture.output(bib <- read_bib("../../whistle/master.bib", quiet = FALSE),
                         type = "message")
}



