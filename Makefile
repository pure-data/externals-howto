HOWTO_EN=HOWTO-externals-en
HOWTO_DE=HOWTO-externals-de

HOWTO_EXAMPLES=example1  example2  example3  example4

HTMLDIR_EN=HOWTO
HTMLDIR_DE=HOWTO-de

LATEX=latex
DVIPS=dvips
PDFLATEX=pdflatex
LATEX2HTML=latex2html
LATEX2HTML_OPTIONS=-html_version 4.0,latin1,unicode -split 4

default: en_pdf

TARGETS: default \
	en_ps en_pdf en_html de_ps de_pdf de_html ps pdf html \
	clean cleaner distclean \
	examples $(HOWTO_EXAMPLES)

.PHONY: $(TARGETS)

en_ps: $(HOWTO_EN).ps

en_pdf: $(HOWTO_EN).pdf

en_html: $(HOWTO_EN).tex
	mkdir -p ${HTMLDIR_EN}
	$(LATEX2HTML) $(LATEX2HTML_OPTIONS) -dir $(HTMLDIR_EN) $<

de_ps: $(HOWTO_DE).ps

de_pdf: $(HOWTO_DE).pdf

de_html: $(HOWTO_DE).tex
	mkdir -p ${HTMLDIR_DE}
	$(LATEX2HTML) $(LATEX2HTML_OPTIONS) -dir $(HTMLDIR_DE) $<

ps: en_ps de_ps

pdf: en_pdf de_pdf

html: en_html de_html

clean:
	-rm -f *.aux *.log *.toc *.out *.dvi *~

cleaner: clean
	-rm -f *.ps *.pdf
	-rm -rf $(HTMLDIR_EN) $(HTMLDIR_DE)

distclean: cleaner
	@for d in ${HOWTO_EXAMPLES}; do ${MAKE} -C $$d clean; done

%.dvi:
	$(LATEX) $*.tex
	$(LATEX) $*.tex


%.ps: %.dvi
	$(DVIPS) $*.dvi


%.pdf:
	$(PDFLATEX) $*.tex
	$(PDFLATEX) $*.tex

examples: $(HOWTO_EXAMPLES)
	echo made examples

$(HOWTO_EXAMPLES):
	$(MAKE) -C $@
