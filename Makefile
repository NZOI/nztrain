# Edit here - set path to you directory with config.json & fonts
 
FONT_DIR      ?= ./vendor/fontello
 
### Don't edit below ###
 
FONTELLO_HOST ?= http://fontello.com

CSS_FONT_RELATIVE_PATH ?= fontello/
 
fontopen:
	@if test ! `which curl` ; then \
		echo 'Install curl first.' >&2 ; \
		exit 128 ; \
		fi
	curl --silent --show-error --fail --output .fontello \
		--form "config=@${FONT_DIR}/config.json" \
		${FONTELLO_HOST}
	x-www-browser ${FONTELLO_HOST}/`cat .fontello`
 
 
fontsave:
	@if test ! `which unzip` ; then \
		echo 'Install unzip first.' >&2 ; \
		exit 128 ; \
		fi
	@if test ! -e .fontello ; then \
		echo 'Run `make fontopen` first.' >&2 ; \
		exit 128 ; \
		fi
	rm -rf .fontello.src .fontello.zip
	curl --silent --show-error --fail --output .fontello.zip \
		${FONTELLO_HOST}/`cat .fontello`/get
	unzip .fontello.zip -d .fontello.src
	rm -rf ${FONT_DIR}
	mv `find ./.fontello.src -maxdepth 1 -name 'fontello-*'` ${FONT_DIR}
	find vendor/fontello/css/ -type f -exec sed -i 's|../font/|${CSS_FONT_RELATIVE_PATH}|g' {} ';'
	rm -rf .fontello.src .fontello.zip

