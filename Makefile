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

SUBSECTIONS = $(subst :,\:,$(wildcard $(patsubst %,%:*.md, $(SECTIONS))))

sidebar:
	set -xeu ; \
	for section in $(SECTIONS) ; do \
		title=$$(echo "$${section}" | tr - ' ') ; \
		if test -d $${section} ; then \
			echo '<details>' ; \
			echo '  <summary>' ; \
			echo "    <a href='/$${section}'>$${title}</a><br/>" ; \
			echo '  </summary>' ; \
			ls $${section} | sort | while read subsection ; do \
				href=$$(basename $${subsection} .md) ; \
				title=$$(echo $${href} | sed -e 's/-/ /g') ; \
				echo "  <a href='/$${section}/$${href}'>$${title}</a><br/>" ; \
			done ; \
			echo '</details>' ; \
		else \
			echo "<a href='/$${section}'>$${title}</a><br/>" ; \
		fi ; \
		echo ; \
	done > _includes/_sidebar.html

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
