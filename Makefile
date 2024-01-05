ADDON_NAME := nekometer
ADDON_DIR := $(shell find ~ -path '*/World of Warcraft/_retail_/Interface/AddOns' 2>/dev/null | head -1)

install: uninstall
	mkdir -p "$(ADDON_DIR)/$(ADDON_NAME)"
	cp -rf . "$(ADDON_DIR)/$(ADDON_NAME)"

uninstall:
	rm -rf "$(ADDON_DIR)/$(ADDON_NAME)"

release:
	zip -r nekometer.zip ../nekometer/*