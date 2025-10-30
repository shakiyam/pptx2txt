MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --warn-undefined-variables
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
ALL_TARGETS := $(shell grep -E -o ^[0-9A-Za-z_-]+: $(MAKEFILE_LIST) | sed 's/://')
.PHONY: $(ALL_TARGETS)
.DEFAULT_GOAL := help

all: lint update_requirements_dev build_dev mypy update_requirements build test ## Lint, update requirements.txt, build, and test

build: ## Build image 'shakiyam/pptx2txt' from Dockerfile
	@echo -e "\033[36m$@\033[0m"
	@./tools/build.sh ghcr.io/shakiyam/pptx2txt Dockerfile

build_dev: ## Build image 'shakiyam/pptx2txt_dev' from Dockerfile.dev
	@echo -e "\033[36m$@\033[0m"
	@./tools/build.sh ghcr.io/shakiyam/pptx2txt_dev Dockerfile.dev

hadolint: ## Lint Dockerfile
	@echo -e "\033[36m$@\033[0m"
	@./tools/hadolint.sh Dockerfile Dockerfile.dev

help: ## Print this help
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[0-9A-Za-z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

lint: ruff hadolint shellcheck shfmt ## Lint for all dependencies

mypy: ## Lint Python code
	@echo -e "\033[36m$@\033[0m"
	@[[ -d .mypy_cache ]] || mkdir .mypy_cache
	@./pptx2txt_dev mypy *.py

ruff: ## Lint Python code
	@echo -e "\033[36m$@\033[0m"
	@./tools/ruff.sh check

shellcheck: ## Lint shell scripts
	@echo -e "\033[36m$@\033[0m"
	@./tools/shellcheck.sh pptx2txt pptx2txt_dev test/*.sh tools/*.sh

shfmt: ## Lint shell scripts
	@echo -e "\033[36m$@\033[0m"
	@./tools/shfmt.sh -l -d -i 2 -ci -bn pptx2txt pptx2txt_dev test/*.sh tools/*.sh

test: ## Test pptx2txt
	@echo -e "\033[36m$@\033[0m"
	@./test/test_basic.sh
	@./test/clean.sh
	@./test/test_error_scenarios.sh

update_requirements: ## Update requirements.txt
	@echo -e "\033[36m$@\033[0m"
	@./tools/uv.sh pip compile --upgrade --strip-extras --output-file requirements.txt pyproject.toml

update_requirements_dev: ## Update requirements_dev.txt
	@echo -e "\033[36m$@\033[0m"
	@./tools/uv.sh pip compile --upgrade --strip-extras --extra dev --output-file requirements_dev.txt pyproject.toml
