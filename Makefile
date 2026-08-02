.DEFAULT_GOAL := help

FVM ?= fvm
DART ?= $(FVM) dart
FLUTTER ?= $(FVM) flutter
BUNDLE_CMD ?= bundle
IOS_BUNDLE_DIR ?= /tmp/tsubusu-bundle
FASTLANE_CMD ?= $(BUNDLE_CMD) exec fastlane
IOS_BUILD_ENV = $(if $(BUILD_NAME),BUILD_NAME='$(BUILD_NAME)') $(if $(BUILD_NUMBER),BUILD_NUMBER='$(BUILD_NUMBER)')
MACOS_BUNDLE_ID ?= com.example.tsubusu
MACOS_APP_NAME ?= tsubusu
MACOS_APP_DEST ?= /Applications/$(MACOS_APP_NAME).app

.PHONY: help clean-generated clean-generated-full clean-generated-dry-run flutter-clean \
	ios-fastlane-install ios-ipa ios-beta ios-release macos-install

help:
	@echo "Available targets:"
	@echo "  clean-generated          Remove normal Flutter/Dart generated state"
	@echo "  clean-generated-full     Also remove regenerated native platform state"
	@echo "  clean-generated-dry-run  Preview the full cleanup without deleting files"
	@echo "  flutter-clean             Run Flutter's standard project cleanup"
	@echo "  ios-fastlane-install      Install the locked iOS fastlane dependencies"
	@echo "  ios-ipa                   Build an iOS IPA with Flutter"
	@echo "  ios-beta                  Build or reuse an IPA and upload it to TestFlight"
	@echo "  ios-release               Upload IPA_PATH to App Store Connect without submitting"
	@echo "  macos-install             Build, back up data, install, and launch the macOS app"

clean-generated:
	$(DART) run tool/clean_generated.dart --normal

clean-generated-full:
	$(DART) run tool/clean_generated.dart --full

clean-generated-dry-run:
	$(DART) run tool/clean_generated.dart --full --dry-run

flutter-clean:
	$(FLUTTER) clean

ios-fastlane-install:
	cd ios && BUNDLE_PATH=$(IOS_BUNDLE_DIR) $(BUNDLE_CMD) install

ios-ipa: ios-fastlane-install
	cd ios && $(IOS_BUILD_ENV) BUNDLE_PATH=$(IOS_BUNDLE_DIR) $(FASTLANE_CMD) ios build

ios-beta: ios-fastlane-install
	cd ios && $(IOS_BUILD_ENV) BUNDLE_PATH=$(IOS_BUNDLE_DIR) $(if $(IPA_PATH),IPA_PATH='$(IPA_PATH)') $(FASTLANE_CMD) ios beta

ios-release: ios-fastlane-install
	@test -n "$(IPA_PATH)" || (echo "Usage: make ios-release IPA_PATH=/path/to/app.ipa" && exit 1)
	cd ios && IPA_PATH='$(IPA_PATH)' BUNDLE_PATH=$(IOS_BUNDLE_DIR) $(FASTLANE_CMD) ios release

macos-install:
	@set -eu; \
	if pgrep -x "$(MACOS_APP_NAME)" >/dev/null 2>&1; then \
		echo "Please close $(MACOS_APP_NAME) before running make macos-install."; \
		exit 1; \
	fi; \
	$(FLUTTER) build macos --release; \
	timestamp=$$(date +%Y%m%d-%H%M%S); \
	prefs="$$HOME/Library/Containers/$(MACOS_BUNDLE_ID)/Data/Library/Preferences/$(MACOS_BUNDLE_ID).plist"; \
	if [ -f "$$prefs" ]; then \
		cp "$$prefs" "$$HOME/Desktop/$(MACOS_APP_NAME)-preferences-backup-$$timestamp.plist"; \
		echo "Preferences backed up to Desktop."; \
	else \
		echo "No existing preferences file found; continuing."; \
	fi; \
	if [ -d "$(MACOS_APP_DEST)" ]; then \
		old_app="/Applications/$(MACOS_APP_NAME)-old.app"; \
		rm -rf "$$old_app"; \
		mv "$(MACOS_APP_DEST)" "$$old_app"; \
		echo "Previous app moved to $$old_app."; \
	fi; \
	ditto "build/macos/Build/Products/Release/$(MACOS_APP_NAME).app" "$(MACOS_APP_DEST)"; \
	open "$(MACOS_APP_DEST)"
