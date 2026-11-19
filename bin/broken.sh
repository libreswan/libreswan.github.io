#!/bin/sh

set -eu

for md in "$@" ; do
    {
	cat -n "${md}"
    } | {
	# print references [TITLE](/Link) as FILE:LINE /Link
	sed -n -e 's; *\([0-9]*\).*](\([^)#]*\)[^)]*).*;\1 \2;p'
    } | {
	# ignore real links
	grep -v -e http: -e https: -e git:
    } | {
	while read line link ; do
	    case "${link}" in
		[^/]* ) echo "check:${md}:${line}: missing / in ${link}" ; continue ;;
		*.jpg|*.pdf|*.png|*.fig) ;;
		/*/ ) link="${link}/README.md" ;;
		/* ) link="${link}.md" ;;
	    esac
	    if test ! -r ".${link}" ; then
		echo "check:${md}:${line}: missing file .${link}"
	    fi
	done
    }
done
