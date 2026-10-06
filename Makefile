MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --warn-undefined-variables
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
ALL_TARGETS := $(shell grep -E -o ^[0-9A-Za-z_-]+: $(MAKEFILE_LIST) | sed 's/://')
.PHONY: $(ALL_TARGETS)
.DEFAULT_GOAL := help

all: check_for_updates format lint update_requirements_dev mypy update_requirements test ## Check for updates, format, lint, update requirements, mypy, build, and test

actionlint: ## Lint GitHub Actions workflow files
	@echo -e "\033[36m$@\033[0m"
	@./tools/actionlint.sh

build: ## Build image 'shakiyam/pptx2txt' from Dockerfile
	@echo -e "\033[36m$@\033[0m"
	@./tools/build.sh ghcr.io/shakiyam/pptx2txt Dockerfile

build_dev: ## Build image 'shakiyam/pptx2txt_dev' from Dockerfile.dev
	@echo -e "\033[36m$@\033[0m"
	@./tools/build.sh ghcr.io/shakiyam/pptx2txt_dev Dockerfile.dev

check_for_action_updates: ## Check for GitHub Actions updates
	@echo -e "\033[36m$@\033[0m"
	@./tools/check_for_action_updates.sh actions/checkout
	@./tools/check_for_action_updates.sh docker/build-push-action
	@./tools/check_for_action_updates.sh docker/login-action
	@./tools/check_for_action_updates.sh docker/setup-buildx-action
	@./tools/check_for_action_updates.sh docker/setup-qemu-action

check_for_image_updates: ## Check for image updates
	@echo -e "\033[36m$@\033[0m"
	@./tools/check_for_image_updates.sh "$$(awk '/^FROM /{print $$2; exit}' Dockerfile)" python:slim
	@./tools/check_for_image_updates.sh "$$(awk '/COPY --from=.*astral-sh\/uv/{sub(/.*--from=/,""); print $$1}' Dockerfile)" ghcr.io/astral-sh/uv:latest
	@./tools/check_for_image_updates.sh "$$(awk -F'"' '/readonly UV_IMAGE=/{print $$2}' tools/uv.sh)" ghcr.io/astral-sh/uv:python3.14-trixie-slim

check_for_updates: check_for_action_updates check_for_image_updates ## Check for updates to all dependencies

dockerfmt: ## Format Dockerfile
	@echo -e "\033[36m$@\033[0m"
	@./tools/dockerfmt.sh -i 2 -n -w Dockerfile Dockerfile.dev

format: dockerfmt ruff_format shfmt yamlfmt ## Run all formatting

hadolint: ## Lint Dockerfile
	@echo -e "\033[36m$@\033[0m"
	@./tools/hadolint.sh Dockerfile Dockerfile.dev

help: ## Print this help
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[0-9A-Za-z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

hooks: ## Install git hooks
	@echo -e "\033[36m$@\033[0m"
	@ln -sf ../../hooks/pre-commit .git/hooks/pre-commit
	@echo "Git hooks installed"

lint: actionlint hadolint markdownlint ruff shellcheck zizmor ## Run all linting

markdownlint: ## Lint Markdown files
	@echo -e "\033[36m$@\033[0m"
	@./tools/markdownlint-cli2.sh "*.md"

mypy: build_dev ## Check Python types
	@echo -e "\033[36m$@\033[0m"
	@[[ -d .mypy_cache ]] || mkdir .mypy_cache
	@./pptx2txt_dev mypy *.py

ruff: ## Lint Python code
	@echo -e "\033[36m$@\033[0m"
	@./tools/ruff.sh check

ruff_format: ## Format Python code
	@echo -e "\033[36m$@\033[0m"
	@./tools/ruff.sh format

shellcheck: ## Lint shell scripts
	@echo -e "\033[36m$@\033[0m"
	@./tools/shellcheck.sh pptx2txt pptx2txt_dev test/*.sh tools/*.sh hooks/*

shfmt: ## Format shell scripts
	@echo -e "\033[36m$@\033[0m"
	@./tools/shfmt.sh -l -w -i 2 -ci -bn pptx2txt pptx2txt_dev test/*.sh tools/*.sh hooks/*

test: build ## Test pptx2txt
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

yamlfmt: ## Format YAML files
	@echo -e "\033[36m$@\033[0m"
	@./tools/yamlfmt.sh .github/zizmor.yml .github/workflows/*.yml

zizmor: ## Lint GitHub Actions workflows for security issues
	@echo -e "\033[36m$@\033[0m"
	@./tools/zizmor.sh .
