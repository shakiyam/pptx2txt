MAKEFLAGS += --warn-undefined-variables
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help
.SUFFIXES:

ALL_TARGETS := $(shell egrep -o ^[0-9A-Za-z_-]+: $(MAKEFILE_LIST) | sed 's/://')

.PHONY: $(ALL_TARGETS)

all: shellcheck shfmt hadolint flake8 update_requirements build test ## Lint, update requirements.txt, build, and test
	@:

build: ## Build image 'shakiyam/pptx2txt' from Dockerfile
	@echo -e "\033[36m$@\033[0m"
	@./tools/build.sh shakiyam/pptx2txt Dockerfile

flake8: ## Lint Python code
	@echo -e "\033[36m$@\033[0m"
	@./tools/flake8.sh

hadolint: ## Lint Dockerfile
	@echo -e "\033[36m$@\033[0m"
	@./tools/hadolint.sh Dockerfile

help: ## Print this help
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[0-9A-Za-z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

shellcheck: ## Lint shell scripts
	@echo -e "\033[36m$@\033[0m"
	@./tools/shellcheck.sh pptx2txt pptx2txt_dev test/*.sh tools/*.sh

shfmt: ## Lint shell scripts
	@echo -e "\033[36m$@\033[0m"
	@./tools/shfmt.sh -l -d -i 2 -ci -bn -kp pptx2txt pptx2txt_dev test/*.sh tools/*.sh

test: ## Test pptx2txt
	@echo -e "\033[36m$@\033[0m"
	@./test/run.sh
	@./test/clean.sh

update_requirements: ## Update requirements.txt
	@echo -e "\033[36m$@\033[0m"
	@./tools/pip-compile.sh --upgrade
