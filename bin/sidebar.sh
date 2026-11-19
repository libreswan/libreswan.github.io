#!/bin/sh

set -xeu

for section in "$@" ; do
    title=$(echo "${section}" | tr - ' ')
    if test -d ${section} ; then
	echo '<details>'
	# section
	echo '  <summary>'
	if test -r ${section}/README.md ; then
	    echo "    <a href='/${section}/'>${title}</a>"
	else
	    echo "    ${title}"
	fi
	echo '  </summary>'
	# subsections
	echo '  <small>'
	sort=
	case ${section} in
	    Completed-Projects ) sort='sort -r' ;;
	    * ) sort='sort' ;;
	esac
	for sub in $(ls ${section} | ${sort} ) ; do
	    case ${sub} in
		README.md ) continue ;;
		*.md ) ;;
		* ) test -d ${section}/${sub} || continue ;;
	    esac
	    subsection=$(basename ${sub} .md)
	    title=$(echo ${subsection} | tr - ' ')
	    if test -d ${section}/${subsection} ; then
		echo '    <details>'
		echo '      <summary>'
		echo "        <a href='/${section}/${subsection}'>${title}</a>"
		echo '      </summary>'
		for subsub in $(ls ${section}/${subsection}/ | sort) ; do
		    case ${subsub} in
			README.md ) continue ;;
			*.md ) ;;
			* ) test -d ${section}/${sub}/${subsub} || continue ;;
		    esac
		    subsubsection=$(basename ${subsub} .md)
		    title=$(echo ${subsubsection} | tr - ' ')
		    echo "      <a href='/${section}/${subsection}/${subsubsection}'>${title}</a><br/>"
		done
		echo '    </details>'
	    else
		echo "    <a href='/${section}/${subsection}'>${title}</a><br/>"
	    fi
	done
	echo '  </small>'
	echo '</details>'
    else
	echo "<a href='/${section}'>${title}</a><br/>"
    fi
    echo
done
