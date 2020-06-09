#
#   Create the local references.bib file from the private central bib file
#

library(stringr)
library(RefManageR)

setwd(here::here("./"))

source("https://raw.githubusercontent.com/andybega/condensebib/master/R/reduce-bib.R")

reduce_bib(
  file = "paper.Rmd",
  master_bib = "../../whistle/master.bib",
  out_bib    = "references.bib"
)

# Change \aa to \r{a}
bib <- readLines("references.bib")
bib <- str_replace_all(bib, "\\\\aa", "\\\\r\\{a\\}")
writeLines(bib, "references.bib")
