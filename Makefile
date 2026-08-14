.PHONY: sitemap.txt
sitemap.txt:
	find wiki -name '*.md' -print | while read md ; do \
		echo "https://libreswan.github.io/wiki/$$(basename $$md .md)" ; \
	done > sitemap.txt
