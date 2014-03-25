HOWTO_EN=HOWTO-externals-en
HOWTO_DE=HOWTO-externals-de

HOWTO_EXAMPLES=example1  example2  example3  example4

HTMLDIR_EN=HOWTO
HTMLDIR_DE=HOWTO-de

LATEX=latex
DVIPS=dvips
PDFLATEX=pdflatex
HTLATEX=htlatex
HTLATEX_OPTIONS2=html,2,next,fn-in
HTLATEX_OPTIONS3=
## htlatex HOWTO-externals-en "html,2,next" "" -dHOWTO/

default: en_pdf

TARGETS: default \
	en_ps en_pdf en_html de_ps de_pdf de_html ps pdf html \
	clean cleaner distclean \
	examples $(HOWTO_EXAMPLES)

.PHONY: $(TARGETS)

en_ps: $(HOWTO_EN).ps
de_ps: $(HOWTO_DE).ps

en_pdf: $(HOWTO_EN).pdf
de_pdf: $(HOWTO_DE).pdf

en_html: $(HOWTO_EN).tex $(HOWTO_EN).pdf
	mkdir -p $(HTMLDIR_EN)
	$(HTLATEX) $< "$(HTLATEX_OPTIONS2)" "$(HTLATEX_OPTIONS3)" "-d$(HTMLDIR_EN)/"
	cp "$(HOWTO_EN).pdf" "$(HTMLDIR_EN)/pd-externals-HOWTO.pdf"

#de_html: $(HOWTO_DE).tex
#	mkdir -p $(HTMLDIR_DE)
#	$(HTLATEX) $< "$(HTLATEX_OPTIONS2)" "$(HTLATEX_OPTIONS3)" "-d$(HTMLDIR_DE)/"
de_html::
	@echo "ignoring target '$@'"

ps: en_ps de_ps

pdf: en_pdf de_pdf

html: en_html de_html

clean:
	-rm -f *.aux *.log *.toc *.out *.dvi
	-rm -f *.idv *.lg *.tmp *.xref *.4ct *.4tc
	-rm -f *.css *.html
	-rm -f *~

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


%.pdf: %.tex
	$(PDFLATEX) $*.tex
	$(PDFLATEX) $*.tex

examples: $(HOWTO_EXAMPLES)
	echo made examples

$(HOWTO_EXAMPLES):
	$(MAKE) -C $@



