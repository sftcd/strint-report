# We probably want the report in a few different formats: ASCII text
# in the RFC style[1], HTML for the workshop mini-site[2], HTML for
# the STREWS site[3], and maybe PDF to submit to the EC and the
# reviewers.
#
# This Makefile contains the recipes for generating the different
# formats from the XML source:
#
# .txt   Official RFC format
# .html  HTML format as made by xml2rfc
# .pdf   PDF version of that HTML
# .src   Uploading this to [4] creates [5]: HTML in the W3C workshop style
#
# There are various ways to convert files between formats. This
# Makefile uses xml2rfc (available from various distributions,
# including Debian, or see [6]). The PDF is created from the HTML with
# prince[7]. The .src is created with a special-purpose XSLT script.
#
# ToDo: Add something to make writing the bibliography easier (bibtex2rfc?)
#
# [1] http://tools.ietf.org/tools/xml2rfc/public/rfc/html/rfc2629.html
# [2] https://www.w3.org/2014/strint/
# [3] http://www.strews.eu/
# [4] https://www.w3.org/2014/strint/report.src
# [5] https://www.w3.org/2014/strint/report.html
# [6] http://tools.ietf.org/tools/
# [7] http://www.princexml.com/

NAME = draft-iab-strint-report

ifneq ($(shell which prince),)
PRINCE = prince
else
PRINCE = @echo No pdf: 
endif

all: $(NAME).txt $(NAME).html $(NAME).pdf $(NAME).src
clean:; rm -f $(NAME).txt $(NAME).html $(NAME).pdf $(NAME).src
%.txt: %.xml; xml2rfc $< $@
%.html: %.xml; xml2rfc $< $@
%.pdf: %.html; $(PRINCE) $< -o $@
%.src: %.xml; xsltproc -o $@ rfc2629-to-html.xslt $<
.PHONY: all clean
