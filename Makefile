HOWTO=HOWTO-externals-en

HOWTO_EXAMPLES=example1  example2  example3  example4

HTMLDIR=HOWTO

LATEX=latex
DVIPS=dvips
PDFLATEX=pdflatex
HTLATEX=htlatex
HTLATEX_OPTIONS2=html,2,next,fn-in
HTLATEX_OPTIONS3=
## htlatex HOWTO-externals-en "html,2,next" "" -dHOWTO/

default: pdf

TARGETS: default \
	ps pdf html \
	clean cleaner distclean \
	examples $(HOWTO_EXAMPLES)

.PHONY: $(TARGETS)

ps: $(HOWTO).ps
pdf: $(HOWTO).pdf

html: $(HOWTO).tex $(HOWTO).pdf
	mkdir -p $(HTMLDIR)
	$(HTLATEX) $< "$(HTLATEX_OPTIONS2)" "$(HTLATEX_OPTIONS3)" "-d$(HTMLDIR)/"
	cp $(HOWTO).pdf "$(HTMLDIR)/pd-externals-HOWTO.pdf"

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

%.dvi: $.tex
	$(LATEX) $<
	$(LATEX) $<

%.ps: %.dvi
	$(DVIPS) $<

%.pdf: %.tex
	$(PDFLATEX) $<
	$(PDFLATEX) $<

examples: $(HOWTO_EXAMPLES)
	echo made examples

$(HOWTO_EXAMPLES):
	$(MAKE) -C $@
