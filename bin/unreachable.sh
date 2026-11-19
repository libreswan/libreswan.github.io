#!/bin/sh

set -eu

for md in "$@" ; do
    p=$(echo "${md}" | sed -e 's;.md$;;')
    grep -e "\(/${md}\)" *.md > /dev/null ||
	grep -e "'/${md}" _includes/_sidebar.html > /dev/null ||
	echo $md
done
