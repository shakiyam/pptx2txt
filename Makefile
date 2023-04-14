MAKEFLAGS += --warn-undefined-variables
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help
.SUFFIXES:

ALL_TARGETS := $(shell egrep -o ^[0-9A-Za-z_-]+: $(MAKEFILE_LIST) | sed 's/://')

.PHONY: $(ALL_TARGETS)

all: lint update_requirements_dev build_dev mypy update_requirements build test ## Lint, update requirements.txt, build, and test

build: ## Build image 'shakiyam/pptx2txt' from Dockerfile
	@echo -e "\033[36m$@\033[0m"
	@./tools/build.sh ghcr.io/shakiyam/pptx2txt Dockerfile

build_dev: ## Build image 'shakiyam/pptx2txt_dev' from Dockerfile.dev
	@echo -e "\033[36m$@\033[0m"
	@./tools/build.sh ghcr.io/shakiyam/pptx2txt_dev Dockerfile.dev

flake8: ## Lint Python code
	@echo -e "\033[36m$@\033[0m"
	@./tools/flake8.sh

hadolint: ## Lint Dockerfile
	@echo -e "\033[36m$@\033[0m"
	@./tools/hadolint.sh Dockerfile Dockerfile.dev

help: ## Print this help
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[0-9A-Za-z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

lint: flake8 hadolint shellcheck shfmt ## Lint for all dependencies

mypy: ## Lint Python code
	@echo -e "\033[36m$@\033[0m"
	@./tools/mypy.sh ghcr.io/shakiyam/pptx2txt_dev --ignore-missing-imports pptx2txt.py

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

update_requirements_dev: ## Update requirements_dev.txt
	@echo -e "\033[36m$@\033[0m"
	@./tools/pip-compile.sh requirements_dev.in --output-file requirements_dev.txt --upgrade
