#
#		Run "make" or "make all" to compile the paper PDF and Word versions
#
#		Run "make clean" to remove intermediary artifacts (.md, .tex, .out)
#

all: paper.pdf paper.docx
.PHONY: all

paper.pdf: paper.Rmd
		Rscript -e 'rmarkdown::render("paper.Rmd")'

paper.docx: paper.md
		pandoc paper.md -o paper.docx

clean:
		rm paper.tex paper.md paper.out
.PHONY: clean
