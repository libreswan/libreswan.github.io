.PHONY: default all sidebar sitemap.txt
all default: broken sidebar

.PHONY: sitemap.txt
sitemap.txt:
	find wiki -name '*.md' -print | while read md ; do \
		echo "https://libreswan.github.io/wiki/$$(basename $$md .md)" ; \
	done > sitemap.txt

SECTIONS += Support
SECTIONS += FAQ
SECTIONS += HOWTO
SECTIONS += GSoC-2027
SECTIONS += Completed-Projects
SECTIONS += IRC
SECTIONS += Hacking
SECTIONS += Testing
SECTIONS += KVM-Test-Framework
SECTIONS += Internals
SECTIONS += Security
SECTIONS += Meetups
SECTIONS += Obsolete-HOWTOs

.PHONY: clean
clean:
	rm -f *.tmp

ASCIIDOC_TITLE = sed \
	-e '\# save LINK to hold space' \
	-e 's;.md$$;;' \
	-e 'h' \
	-e '\# build TITLE' \
	-e 's;-; ;g' \
	-e 's;[^:]*: ;;' \
	-e '\# switch-concat forming LINK NL TITLE' \
	-e 'x' \
	-e 'G' \
	-e 's;\([^\n]*\)\n\(.*\);* link:./\1[\2];'

SUBSECTIONS = $(subst :,\:,$(wildcard $(patsubst %,%:*.md, $(SECTIONS))))

sidebar:
	set -xeu ; \
	for section in $(SECTIONS) ; do \
		regex="$${section}:*.md" ; \
		subsections=$$(echo $${regex}) ; \
		title=$$(echo "$${section}" | tr - ' ') ; \
		if test "$${subsections}" == "$${regex}" ; then \
			echo "<a href='$${section}'>$${title}</a><br/>" ; \
		elif test -r "$${section}.md" ; then \
			echo "<a href='$${section}'>$${title}</a><br/>" ; \
		else \
			echo "$${title}<br/>" ; \
		fi ; \
		if test "$${subsections}" != "$${regex}" ; then \
			ls $${section}:*.md \
			| sed -e 's/.md$$//' \
			| sort \
			| while read subsection ; do \
				echo "<a href='$${subsection}'>$${subsection}</a><br/>" ; \
			done ; \
		fi ; \
		echo ; \
	done > _sidebar.html

# see
# https://emacs.stackexchange.com/questions/59804/compilation-mode-and-next-error-confusion
# for why check: is included with the FILE:LINE prefix (its to get
# around : confusing emacs).

broken:
	set -eu ; \
	for md in *.md ; do \
		cat -n "$${md}" \
		| sed -n -e 's; *\([0-9]*\).*](\([^)#]*\)[^)]*).*;\1 \2;p' \
		| grep -v -e http: -e https: -e git: \
		| while read line link ; do \
			case "$${link}" in \
			[^.]* ) echo "check:$${md}:$${line}: missing ./ in $${link}" ; continue ;; \
			*.jpg|*.pdf|*.png|*.fig) ;; \
			./* ) link="$${link}.md" ;; \
			esac ; \
			if test ! -r "$${link}" ; then \
				echo "check:$${md}:$${line}: missing file $${link}" ; \
			fi ; \
		done ; \
	done

.PHONY: unreachable
unreachable:
	set -eu ; \
	for md in *.md ; do \
		f=$$(basename $${md} .md) ; \
		grep -e '\(\./'"$${f}"'\)' *.md > /dev/null || \
		grep -e 'link:\./'"$${f}"'\[' *.asciidoc > /dev/null || \
		echo $$md ; \
	done
