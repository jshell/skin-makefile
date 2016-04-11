# Skin Makefile Runner 0.1.0-alpha

# Download the skin.mk if the curl configuration file 'skin.mk.curl' is newer then the 'skin.mk' file.
# Run the make command with the skin.mk file.
skin.mk : skin.mk.curl
	@(if test ! $@ -nt $<; then \
	echo "Get $@"; \
	curl --silent --show-error --fail --location --config $< --output $@ || (echo "Failed to get file."; exit 1); \
	fi);
	@$(MAKE) -f $@ $(MAKECMDGOALS)

.PHONY : skin.mk

% :
	@$(MAKE) -f skin.mk $(MAKECMDGOALS)
