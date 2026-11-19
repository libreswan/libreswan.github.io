#!/bin/sh

set -xeu

for section in "$@" ; do
    title=$(echo "${section}" | tr - ' ')
    if test -d ${section} ; then
	echo '<details>'
	# section
	echo '  <summary>'
	if test -r ${section}.md ; then
	    echo "    <a href='/${section}'>${title}</a>"
	elif test -r ${section}/README.md ; then
	    echo "    <a href='/${section}/'>${title}</a>"
	else
	    echo "    ${title}"
	fi
	echo '  </summary>'
	# subsections
	echo '  <small>'
	{
	    ls ${section}/*.md
	} | {
	    case ${section} in
		Completed-Projects ) sort -r ;;
		* ) sort ;;
	    esac
	} | {
	    grep -v /README.md
	} | while read subsection ; do
	    subsection=$(basename ${subsection} .md)
	    title=$(basename ${subsection} .md | tr - ' ')
	    if test -d ${section}/${subsection} ; then
		echo '    <details>'
		echo '      <summary>'
		echo "        <a href='/${section}/${subsection}'>${title}</a>"
		echo '      </summary>'
		ls ${section}/${subsection}/*.md | sort | while read subsubsection ; do
		    subsubsection=$(basename ${subsubsection} .md)
		    title=$(basename ${subsubsection} .md | tr - ' ')
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
