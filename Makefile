.PHONY: default all sidebar sitemap.txt
all default: broken sidebar sitemap.txt

sitemap.txt:
	find * -name '*.md' -print | sed -e 's/.md$$//' | while read md ; do \
		echo "https://libreswan.github.io/$$md" ; \
	done > sitemap.txt

SECTIONS += Support
SECTIONS += FAQ
SECTIONS += HOWTO
SECTIONS += GSoC-2027
SECTIONS += Completed-Projects
SECTIONS += IRC
SECTIONS += Hacking
SECTIONS += Testing
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
			if test -r $${section}.md ; then \
				echo "    <a href='/$${section}'>$${title}</a>" ; \
			else \
				echo "    $${title}" ; \
			fi ; \
			echo '  </summary>' ; \
			echo '  <small>' ; \
			ls $${section}/*.md | sort | while read subsection ; do \
				subsection=$$(basename $${subsection} .md) ; \
				title=$$(basename $${subsection} .md | tr - ' ') ; \
				if test -d $${section}/$${subsection} ; then \
					echo '    <details>' ; \
					echo '      <summary>' ; \
					echo "        <a href='/$${section}/$${subsection}'>$${title}</a>" ; \
					echo '      </summary>' ; \
					ls $${section}/$${subsection}/*.md | sort | while read subsubsection ; do \
						subsubsection=$$(basename $${subsubsection} .md) ; \
						title=$$(basename $${subsubsection} .md | tr - ' ') ; \
						echo "      <a href='/$${section}/$${subsection}/$${subsubsection}'>$${title}</a><br/>" ; \
					done ; \
					echo '    </details>' ; \
				else \
					echo "    <a href='/$${section}/$${subsection}'>$${title}</a><br/>" ; \
				fi ; \
			done ; \
			echo '  </small>' ; \
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
	find * -name '*.md' -print | while read md ; do \
		cat -n "$${md}" \
		| sed -n -e 's; *\([0-9]*\).*](\([^)#]*\)[^)]*).*;\1 \2;p' \
		| grep -v -e http: -e https: -e git: \
		| while read line link ; do \
			case "$${link}" in \
			[^/]* ) echo "check:$${md}:$${line}: missing / in $${link}" ; continue ;; \
			*.jpg|*.pdf|*.png|*.fig) ;; \
			/* ) link="$${link}.md" ;; \
			esac ; \
			if test ! -r ".$${link}" ; then \
				echo "check:$${md}:$${line}: missing file $${link}" ; \
			fi ; \
		done ; \
	done

.PHONY: unreachable
unreachable:
	set -eu ; \
	find * -name '*.md' -print | sed -e 's;.md$$;;' | while read md ; do \
		grep -e "\(/$${md}\)" *.md > /dev/null || \
		grep -e "'/$${md}" _includes/_sidebar.html > /dev/null || \
		echo $$md ; \
	done
