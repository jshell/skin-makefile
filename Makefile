# Skin Makefile 0.1.2
#
# This is a generic Makefile for fetching front end resources and compiling
# them.  It uses some custom extensions `.curl`, `.concat`, `.ugly`,
# `.min.dev.less`, `.css.less`, and others to avoid the need to edit/customize
# the Makefile for individual projects.  It depends on few commands which can
# be seen in the install.sh script.  When starting the first time it will check
# the versions of commands it depends on to see if they are compliant.  The
# Makefile will do an `include` for any files with the `.skin.mk` extension.

# The version check is done on the following commands just before using it.  It
# stores an empty file `.verify_version_*` for each to avoid checking again.
commands := CURL GLUE LESSC OPTIPNG UGLIFYJS CLEANCSS COMPONENT BOWER AUTOPREFIXER SUITCSS MD5SUM JQ
# List commands used only for development and not needed for production
commands_development := $(commands) CSSLINT

# Regular Expression to find a semantic version number for egrep command.
# Matches 1.4.2, 0.9, 3, 0.4.2-alpha, 0.4.2-alpha.2
regex_semver := ([[:digit:]]+\.)?([[:digit:]]+\.)?([[:digit:]]+)(-([[:alnum:]]+)?(\.[[:alnum:]]+)?)?

CURL := curl
version_spec_CURL := >=7
fetch_version_CURL := $(CURL) -V | egrep -o -m1 "$(regex_semver)"

GLUE := glue
version_spec_GLUE := >=0.9,<0.12
# Glue sends the version to stderr. Redirect to stdout and pipe it to egrep.
fetch_version_GLUE := $(GLUE) -v 2>&1 >/dev/null | egrep -o -m1 "$(regex_semver)"

OPTIPNG := optipng
version_spec_OPTIPNG := >=0.6,<0.8
fetch_version_OPTIPNG := $(OPTIPNG) -v | egrep -o -m1 "$(regex_semver)"
OPTIPNG_OPTIONS :=

UGLIFYJS := uglifyjs
version_spec_UGLIFYJS := >=2.4,<3.0
fetch_version_UGLIFYJS := $(UGLIFYJS) -V | egrep -o -m1 "$(regex_semver)"

CLEANCSS := cleancss
version_spec_CLEANCSS := >=2.0,<4.0
fetch_version_CLEANCSS := $(CLEANCSS) -v | egrep -o -m1 "$(regex_semver)"

COMPONENT := component
version_spec_COMPONENT := >=1.0,<2.0
fetch_version_COMPONENT := $(COMPONENT) -V | egrep -o -m1 "$(regex_semver)"

BOWER := bower
version_spec_BOWER := >=1.3,<1.7
fetch_version_BOWER := $(BOWER) -v | egrep -o -m1 "$(regex_semver)"

LESSC := lessc
version_spec_LESSC := >=1.7
fetch_version_LESSC := $(LESSC) -v | egrep -o -m1 "$(regex_semver)"

# For css autoprefixing https://github.com/ai/autoprefixer-cli
AUTOPREFIXER := autoprefixer-cli
version_spec_AUTOPREFIXER := >=2.1
fetch_version_AUTOPREFIXER := $(AUTOPREFIXER) -v | egrep -o -m1 "$(regex_semver)"
AUTOPREFIXER_BROWSERS := "> 1%, last 2 versions, Firefox ESR, Opera 12.1"

# TODO: Setup the verification for stripmq version
STRIPMQ := stripmq
#version_spec_STRIPMQ := >=0.0.5
#fetch_version_STRIPMQ := $(STRIPMQ) -V | egrep -o -m1 "$(regex_semver)"

SUITCSS := suitcss
version_spec_SUITCSS := ==0.5.0-depends
fetch_version_SUITCSS := $(SUITCSS) -V | egrep -o -m1 "$(regex_semver)"

# md5sum via `port install md5sha1sum` on mac osx
MD5SUM := md5sum
version_spec_MD5SUM := >=0.9
fetch_version_MD5SUM := $(MD5SUM) --version | egrep -o -m1 "$(regex_semver)"

# For parsing and editing json files
# http://stedolan.github.io/jq/
# Version 1.3 sends to stderr and 1.4 sends to stdout
JQ := jq
version_spec_JQ := >=1.3
fetch_version_JQ := $(JQ) -V 2>&1 | egrep -o -m1 "$(regex_semver)"


# https://github.com/stubbornella/csslint
### development only
CSSLINT := csslint
version_spec_CSSLINT := >=0.10
fetch_version_CSSLINT := $(CSSLINT) --version | egrep -o -m1 "$(regex_semver)"

# Simple python script that checks version specification.
# https://github.com/jkenlooper/verify_version_spec
VERIFY_VERSION_SPEC := verify_version_spec

# TODO: Setup linting of js code and automatically running tests when developing.

# List all the .verify_version_* commands that will be ran
# (See the VERIFY_VERSION_template below)
verify_commands := $(patsubst %, .verify_version_%, $(commands))
verify_commands_development := $(patsubst %, .verify_version_%, $(commands_development))

# TODO: Use .DELETE_ON_ERROR

STATIC_DIR := static

# Use jq to parse the component.json file for the 'paths' key which has the
# directory names for local components. Also add any files specified in the
# root component.json. Filter out 'null' values from jq and make it blank if no
# component.json.

local_component_paths := $(if $(wildcard component.json), $(filter-out null, $(shell cat component.json | $(JQ) -r -a '.paths | @sh')))
local_component_files := $(if $(wildcard component.json), $(filter-out null, $(shell cat component.json | $(JQ) -r -a '.styles, .scripts, .json, .images, .fonts, .files | @sh')))

# Find all files recursively in the cwd with .curl extension
curl_configs := $(shell find $(STATIC_DIR) -name '*.curl')
# Place curled files next to their .curl
curl_files := $(curl_configs:%.curl=%)

# Concat files
concat_configs := $(shell find $(STATIC_DIR) -name '*.concat')
concat_files := $(concat_configs:%.concat=%)

# Uglify files
ugly_configs := $(shell find $(STATIC_DIR) -name '*.ugly')
ugly_files := $(ugly_configs:%.ugly=%)

# Autoprefix files
autoprefix_configs := $(shell find $(STATIC_DIR) $(local_component_paths) -name '*.autoprefix')
autoprefix_files := $(autoprefix_configs:%.autoprefix=%)

# stripmq files
stripmq_configs := $(shell find $(STATIC_DIR) -name '*.stripmq')
stripmq_files := $(stripmq_configs:%.stripmq=%)

# Clean-css files
cleancss_configs := $(shell find $(STATIC_DIR) $(local_component_paths) -name '*.cleancss')
cleancss_files := $(cleancss_configs:%.cleancss=%)

# Preprocess css files
preprocesscss_configs := $(shell find $(STATIC_DIR) $(local_component_paths) -name '*.preprocess.css')
preprocesscss_files := $(preprocesscss_configs:%.preprocess.css=%)

# Postcss json config files
postcssjson := $(shell find $(STATIC_DIR) -name 'postcss*.json')

# Top level sibling css files to each postcss json config file.
postcssjson_sibling_css_files := $(shell for f in $(postcssjson); do find $$(dirname $$f) -maxdepth 1 -name *.css; done)

# Only use postcss command if these assumptions are correct
postcss := $(if $(postcssjson_sibling_css_files), .postcss, )

min_dev_less := $(shell find $(STATIC_DIR) -name '*.min.dev.less')
dev_css := $(patsubst %.min.dev.less, %.dev.css, $(min_dev_less))
min_css := $(patsubst %.min.dev.less, %.min.css, $(min_dev_less))

css_less := $(shell find $(STATIC_DIR) $(local_component_paths) -name '*.css.less')
lessed_css := $(patsubst %.css.less, %.css, $(css_less))

# Glue sprites
glue_sprite_dirs := $(wildcard $(STATIC_DIR)/css/img/sprites/sprite-*/)
# sort the glue sprites to remove duplicates
glue_sprites := $(sort $(glue_sprite_dirs:%/=%.png))
images_in_sprites := $(if $(wildcard $(STATIC_DIR)/css/img/sprites), $(filter-out $(glue_sprites), $(shell find $(STATIC_DIR)/css/img/sprites -name '*.png' )))

# Set the bower_components variable to be 'bower_components' if bower.json is
# available otherwise set it to an empty string.
bower_components := $(if $(wildcard bower.json),bower_components,)

# Only use glue command if there are sprites to glue
glue := $(if $(glue_sprites), .glue, )

objects := $(if $(wildcard component.json), $(STATIC_DIR)/build components) $(curl_files) $(bower_components) $(concat_files) $(ugly_files) $(dev_css) $(min_css) $(lessed_css) $(autoprefix_files) $(stripmq_files) $(cleancss_files) $(preprocesscss_files) $(if $(wildcard component.json), $(STATIC_DIR)/build components) $(glue) $(glue_sprites)
objects_development := $(objects) $(verify_commands_development)

# clear out any suffixes
.SUFFIXES:

# Allow use of automatic variables in prerequisites
.SECONDEXPANSION:

# all is the default as long as it's first
all :  $(objects) $(concat_configs) $(autoprefix_configs) $(stripmq_configs) $(cleancss_configs) $(preprocesscss_configs) $(postcss)
.PHONY : all manifest clean development production skip.curl

-include *.skin.mk

# Filter out the directories like bower_components, build, and components
compiled_objects := $(filter-out $(STATIC_DIR)/build components $(bower_components) $(glue) $(postcss), $(objects))

# Use 'development' target when just developing on local machine. Includes
# linting of code, updating styleguides, and possibly updating the manifest.
development : all $(objects_development) MANIFEST

# Use 'production' target when just needing to compile the resources and not develop them.
production : all verify

# Verify all the commands and their versions. Using 'Makefile' as
# a prerequisite since the version spec is set for each command as a variable.
# Uses a python script: 'verify_version_spec.py' to test the version
# specification with the version found by running the command. Touches the
# target '.verify_version_*' to avoid checking the commands and versions
# everytime.

define VERIFY_VERSION_template
.verify_version_$(1) : Makefile
	@which $$($(1)) || (echo "command '$$($(1))' not found."; exit 1)
	@echo "Verifying '$$($(1))' version specification '$$(version_spec_$(1))'"
	@$(VERIFY_VERSION_SPEC) --spec="$$(version_spec_$(1))" `$$(fetch_version_$(1))`
	@touch $$@
endef

$(foreach obj,$(sort $(commands) $(commands_development)),$(eval $(call VERIFY_VERSION_template,$(obj))))

# 'md5 -r' is on Mac by default, but doesn't verify.
# 'md5sum' is on Debian and verifies
# 'md5sum' is also available from macports. https://trac.macports.org/browser/trunk/dports/sysutils/md5sha1sum/Portfile
# alias the lowercase manifest
manifest MANIFEST : $(compiled_objects) .verify_version_MD5SUM
	$(MD5SUM) $(compiled_objects) > MANIFEST

verify : all .verify_version_MD5SUM
	$(MD5SUM) -c MANIFEST

# Component is setup here to do `component install` if component.json changes.
# It will do a `component build` when needed.  The build directory that
# Component creates should be published. The files within it should be separate
# from the rest of the Makefile. (Don't try using something that component
# creates in a concat and vice versa.)
components : component.json .verify_version_COMPONENT
	$(COMPONENT) install;
	touch $@;


# Set prerequisites to be components and local components. Sets all files
# within each local component path as a prerequisite, but filters out any that
# are prequisites elsewhere.
other_prequisites := $(autoprefix_configs) $(cleancss_configs) $(preprocesscss_configs) $(css_less)

# TODO: Only include those within the local_components directories
local_components_built_with_make := $(lessed_css)

# (components depends on the jq command to parse the components.json file for prequisites. Hence the .verify_version_JQ here.)
static/build : components $(if $(local_component_paths), $(filter-out $(other_prequisites), $(shell find $(local_component_paths) -type f))) $(local_component_files) $(local_components_built_with_make) .verify_version_COMPONENT .verify_version_JQ
	$(COMPONENT) build --out $(STATIC_DIR)/build;
	touch $@;


# Bower components are only updated if the bower.json has changed.
bower_components : bower.json .verify_version_BOWER
	$(BOWER) install
	@touch $@;


# This needs to match the variables: curl_files and curl_configs
# Check if the resource has moved permantly with 301 error code and show
# a warning.
% : %.curl .verify_version_CURL
	@(if test ! $@ -nt $<; then \
	(if test "301" = `$(CURL) --silent --head --write-out "%{http_code}" --config $< --output /dev/null`; then \
		$(CURL) --silent --head --location --write-out "WARNING: Error 301. Update url in $< to url_effective: %{url_effective}\n" --config $< --output /dev/null; \
		fi); \
	echo "Get $@"; \
	$(CURL) --silent --show-error --fail --location --config $< --output $@ || (echo "Failed. If file exists try: 'make skip.curl' or use touch."; exit 1); \
	fi);

# Skip all downloaded files that already exist.
skip.curl :
	@echo Skipping already downloaded files.
	touch -c $(curl_files);

# Concat task
# The .concat files list the files that will be combined into the target file.
# For example: test.js is built from the files listed in test.js.concat.
% : %.concat
	@echo "Combining files listed in $< to $@";
	@rm -f $@;
	@cat $< | xargs cat >> $@;

# Touch .concat files to trigger rebuilding based on their prerequisites.
$(concat_configs) : %: $$(shell cat $$@)
	@touch $@;


# Uglify (https://github.com/mishoo/UglifyJS2)
# Each ugly file contains the file paths that will be uglified. The name of the
# uglified file is the ugly file without the .ugly extension.  How pretty.
# Note: options can be passed in by adding them to the end of the ugly file.
% : %.ugly .verify_version_UGLIFYJS
	@echo "Uglifying $@ from $(shell cat $<)"
	@$(UGLIFYJS) `cat $<` --output $@

# Touch .ugly files to trigger rebuilding based on their prerequisites.
# Filter out any options by just looking for the .js extension
#	Define a template to create prerequisites for each .ugly file. The
#	prerequisites for an .ugly file are listed inside it.
define UGLY_DEPS_template
$(1) : $$(filter %.js, $$(shell cat $(1)))
	@echo Changed $$?;
	@touch $$@;
endef

$(foreach obj,$(ugly_configs),$(eval $(call UGLY_DEPS_template,$(obj))))


# TODO: Move glue to the extras as glue.skin.mk
# Glue
# Using 'project' arg in order to create the sprites that need creating.
# If there are no changes then glue doesn't rebuild the sprites. Using .glue as
# the target for this.
.glue : $(images_in_sprites) $(wildcard $(STATIC_DIR)/css/img/sprites/sprite.conf) $(wildcard $(STATIC_DIR)/css/img/sprites/*.jinja2) $(wildcard $(STATIC_DIR)/css/img/sprites/*/sprite.conf) $(wildcard $(STATIC_DIR)/css/img/sprites/*/*.jinja2) .verify_version_GLUE .verify_version_OPTIPNG
	$(GLUE) --project --namespace='' --less $(STATIC_DIR)/css/ --img=$(STATIC_DIR)/css/img/sprites --cachebuster $(STATIC_DIR)/css/img/sprites/
	$(OPTIPNG) $(OPTIPNG_OPTIONS) $(glue_sprites);
	@touch .glue

# Less
# Build .min.css and .dev.css versions of any .min.dev.less file that matches.
# (css/site.min.dev.less -> css/site.min.css and css/site.dev.css)
# Uses the lessc --depends option to get prerequisites per .min.dev.less file.
# Includes all glue targets as prerequisites.

define LESS_DEPS_template
$$(patsubst %.min.dev.less, %.dev.css, $(1)) : $(1) $$(filter-out "$(1)", $$(shell $$(LESSC) --depends $(1) $$(STATIC_DIR)/ | sed 's/$$(STATIC_DIR)\/://g')) $$(glue) .verify_version_LESSC .verify_version_AUTOPREFIXER
	$$(LESSC) $$< > $$@;
	$$(AUTOPREFIXER) -b $$(AUTOPREFIXER_BROWSERS) $$@;

$$(patsubst %.min.dev.less, %.min.css, $(1)) : $$(patsubst %.min.dev.less, %.dev.css, $(1)) .verify_version_CLEANCSS
	$$(CLEANCSS) --skip-advanced --skip-aggressive-merging --skip-media-merging --skip-restructuring -o $$@ $$<
endef

$(foreach obj,$(min_dev_less),$(eval $(call LESS_DEPS_template,$(obj))))

# Ignore any errors when imported less files are missing by passing stderr to
# /dev/null. If there is an error then show a warning only and continue. (It's
# okay if no dependencies are listed, cause it's likely that the `make clean`
# command removed them and they'll all be built in this run.)
.ignore_missing_imported_less :
	$(warning "Some less files were not found in the initial '$(LESSC) --depends' check.  If the next '$(LESSC)' command did not cause an error, then you can ignore this warning.")


# Builds a .css version of any .css.less file.
# Includes all glue targets as prerequisites.
define CSS_LESS_template
$$(patsubst %.css.less, %.css, $(1)) : $(1) $$(filter-out "$(1)" /dev/null:, $$(shell $$(LESSC) --depends $(1) /dev/null 2> /dev/null || echo '.ignore_missing_imported_less')) $$(glue) .verify_version_LESSC
	$$(LESSC) $$< > $$@;
endef

$(foreach obj,$(css_less),$(eval $(call CSS_LESS_template,$(obj))))

# Pass in the options in the .stripmq file::
#  static/css/site.dev.css
#  --type screen
#  --width 1280
% : %.stripmq
	$(STRIPMQ) --output $@ --type screen --input `cat $^`;

# Touch .stripmq files to trigger rebuilding based on their prerequisites.
# Filter out any options by just looking for the .css extension
#	Define a template to create prerequisites for each .stripmq file. The
#	prerequisites for an .stripmq file are listed inside it.
define STRIPMQ_template
$(1) : $$(filter %.css, $$(shell cat $(1)))
	@touch $$@;
endef

$(foreach obj,$(stripmq_configs),$(eval $(call STRIPMQ_template,$(obj))))

% : %.autoprefix .verify_version_AUTOPREFIXER
	$(AUTOPREFIXER) -b $(AUTOPREFIXER_BROWSERS) --output $@ `cat $<`;

$(autoprefix_configs) : %: $$(shell cat $$@)
	@touch $@;

# Autoprefixer is run on the .dev.css right after less processes them. It's set
# to auto prefix style rules for browsers that are:
# "> 1%, last 2 versions, Firefox ESR, Opera 12.1"
# See the AUTOPREFIXER_BROWSERS variable.
#
# TODO: Option to set the browsers that autoprefixer will use?  Read from the .less file maybe?
#
# Browsers (autoprefixer -i):
# IE: 11, 10, 9, 8
# Firefox: 30, 29, 24
# Chrome: 35, 34
# Safari: 7, 6.1
# iOS: 7.1, 7.0
# Android: 4.4, 4.3, 4.2, 4.1, 2.3
# Opera: 22, 21, 12.1
# IE Mobile: 10

% : %.cleancss .verify_version_CLEANCSS
	$(CLEANCSS) --skip-advanced --skip-aggressive-merging --skip-media-merging --skip-restructuring --output $@ `cat $<`;

# Touch .cleancss files to trigger rebuilding based on their prerequisites.
# Filter out any options by just looking for the .css extension
#	Define a template to create prerequisites for each .cleancss file. The
#	prerequisites for an .cleancss file are listed inside it.
define CLEANCSS_template
$(1) : $$(filter %.css, $$(shell cat $(1)))
	@touch $$@;
endef

$(foreach obj,$(cleancss_configs),$(eval $(call CLEANCSS_template,$(obj))))


# Preprocess css files using suitcss

% : %.preprocess.css .verify_version_SUITCSS
	$(SUITCSS) $< $@;

# Use '--depends' option with suitcss command to output all the imported css files.
#
# Ignore any errors when imported css files are missing by passing stderr to
# /dev/null. If there is an error then show a warning only and continue. (It's
# okay if no dependencies are listed, cause it's likely that the `make clean`
# command removed them and they'll all be built in this run.)
.ignore_missing_imported_css :
	$(warning "Some css files were not found in the initial '$(SUITCSS) --depends' check.  If the next '$(SUITCSS)' command did not cause an error, then you can ignore this warning.")

$(preprocesscss_configs) : %: $$(shell $(SUITCSS) --depends $$@ 2> /dev/null || echo '.ignore_missing_imported_css')
	@touch $@;

# Build the css if using postcss.  This makes the assumption that the
# postcss.json config file is next to top-level css files.  The top level css
# files have all their imported css files added as prerequisites for the
# .postcss target. Uses the csssources command to output a list of css file
# paths that are imported.  Using the npm config script setup to actually build
# the css.  See the package.json.
#
# A note on the package.json script `buildcss` to build css for the site as
# well as one for old ie:
# "buildcss": "postcss -c static/css/postcss.json"
# "postbuildcss": "mkdir -p dist/css/oldie && postcss -u oldie -u postcss-url -d dist/css/oldie/ dist/css/*.css"
.postcss : $(shell csssources $(postcssjson_sibling_css_files) 2> /dev/null)
	npm run buildcss;
	@touch .postcss;

# TODO: Move these git specific stuff to extras/git.skin.mk
# TODO: Add a .gitattributes file for setting minified files to be binary, and possibly setting their textconf for viewing diffs.

# Automate marking all files that have been created to be ignored by git.
# TODO: include .concat files
built_cache_index_files = $(filter $(shell git ls-files), $(sort $(objects) $(objects_development)))
# TODO: add 'ignore' and 'no_ignore' to .PHONY target?
ignore :
	git update-index --assume-unchanged  $(built_cache_index_files)

no_ignore :
	git update-index --no-assume-unchanged $(built_cache_index_files)

# Remove all built files except those that are tracked by git (built_cache_index_files).
clean :
	rm -rf $(sort $(filter-out $(built_cache_index_files),$(objects) $(objects_development) $(verify_commands) ))
