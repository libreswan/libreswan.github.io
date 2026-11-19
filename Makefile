.PHONY: default all sidebar
all default: broken sidebar

SECTIONS += Support
SECTIONS += FAQ
SECTIONS += HOWTO
SECTIONS += GSoC
SECTIONS += Completed-Projects
SECTIONS += Presentations
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
	./bin/sidebar.sh $(SECTIONS) > _includes/_sidebar.html

# see
# https://emacs.stackexchange.com/questions/59804/compilation-mode-and-next-error-confusion
# for why check: is included with the FILE:LINE prefix (its to get
# around : confusing emacs).

broken:
	./bin/broken.sh $(shell find * -type f -name '*.md')

.PHONY: unreachable
unreachable:
	./bin/unreachable.sh  $(shell find * -type f -name '*.md')
