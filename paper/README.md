Paper materials
============

The paper is written using Rmarkdown. To compile the PDF without RStudio, run the following command in a shell:

```bash
# if the working directory is not already paper/
cd paper

Rscript -e 'rmarkdown::render("paper.Rmd")'
```

Notes:

- Compiling might not work in an interactive R session.
- The paper will _not_ automatically reflect updated in put in `rep_nosmooth/`; use the `update-inputs.R` script to copy over tables and figures to the relevant folders here.

## Misc

For the paper word count:

```bash
ps2ascii paper.pdf | wc -w
```

