# Compile jade templates to pretty html

JADE := jade
version_spec_JADE := >=1.3
fetch_version_JADE := $(JADE) --version | egrep -o -m1 "(\d+\.)?(\d+\.)?(\d+)"

.verify_version_JADE : jade.skin.mk
	@which -s $(JADE) || (echo "command '$(JADE)' not found."; exit 1)
	@echo "Verifying '$(JADE)' version specification '$(version_spec_JADE)'"
	@verify_version_spec --spec="$(version_spec_JADE)" `$(fetch_version_JADE)`
	@touch $@

# Jade files (dev only)
html_jade := $(shell find . -name '*.html.jade')
built_html_from_jade := $(patsubst %.html.jade, %.html, $(html_jade))

objects_development := $(objects_development) .verify_version_JADE $(built_html_from_jade)

# Jade templates
%.html : %.html.jade
	$(JADE) --pretty < $< > $@
