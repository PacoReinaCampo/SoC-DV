rm -f *.pdf
rm -f *.tex

pandoc BOOK.md -s -o SoC-DV.pdf
pandoc BOOK.md -s -o SoC-DV.tex
