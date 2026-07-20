.DEFAULT_GOAL := help

FVM ?= fvm
DART ?= $(FVM) dart
FLUTTER ?= $(FVM) flutter

.PHONY: help clean-generated clean-generated-full clean-generated-dry-run flutter-clean

help:
	@echo "Available targets:"
	@echo "  clean-generated          Remove normal Flutter/Dart generated state"
	@echo "  clean-generated-full     Also remove regenerated native platform state"
	@echo "  clean-generated-dry-run  Preview the full cleanup without deleting files"
	@echo "  flutter-clean             Run Flutter's standard project cleanup"

clean-generated:
	$(DART) run tool/clean_generated.dart --normal

clean-generated-full:
	$(DART) run tool/clean_generated.dart --full

clean-generated-dry-run:
	$(DART) run tool/clean_generated.dart --full --dry-run

flutter-clean:
	$(FLUTTER) clean
