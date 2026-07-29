.DEFAULT_GOAL := help

FVM ?= fvm
DART ?= $(FVM) dart
FLUTTER ?= $(FVM) flutter
BUNDLE_CMD ?= bundle
IOS_BUNDLE_DIR ?= /tmp/tsubusu-bundle
FASTLANE_CMD ?= $(BUNDLE_CMD) exec fastlane
IOS_BUILD_ENV = $(if $(BUILD_NAME),BUILD_NAME='$(BUILD_NAME)') $(if $(BUILD_NUMBER),BUILD_NUMBER='$(BUILD_NUMBER)')

.PHONY: help clean-generated clean-generated-full clean-generated-dry-run flutter-clean \
	ios-fastlane-install ios-ipa ios-beta ios-release

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
