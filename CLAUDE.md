# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

pptx2txt is a Python tool that converts PowerPoint `.pptx` files to text format. It extracts text from slides including regular text, tables, and grouped shapes.

## Key Commands

### Building and Testing

```bash
# Run all checks (lint, build, test)
make all

# Run all tests (both basic and error scenarios)
make test

# Run individual test suites:
./test/test_basic.sh        # Basic functionality tests
./test/test_error_scenarios.sh  # Error handling tests
```

### Linting and Type Checking

```bash
# Run all linting
make lint

# Individual linters:
make flake8    # Python linting
make mypy      # Python type checking
make shellcheck # Shell script linting
make shfmt     # Shell script formatting
make hadolint  # Dockerfile linting
```

### Building Docker Images

```bash
# Build production image
make build

# Build development image (includes dev dependencies)
make build_dev
```

### Updating Dependencies

```bash
# Update production requirements
make update_requirements

# Update development requirements
make update_requirements_dev
```

The project uses `uv` to manage dependencies. Dependencies are defined in `pyproject.toml`:
- Production dependencies: `[project.dependencies]`
- Development dependencies: `[project.optional-dependencies.dev]`

Edit `pyproject.toml` to add/remove dependencies, then run the make commands above to regenerate `*.txt` files with pinned versions.

## Architecture Notes

- **Main Script**: `pptx2txt.py` - Core conversion logic using python-pptx library
- **Shell Wrappers**: `pptx2txt` (production) and `pptx2txt_dev` (development) - Convenient wrapper scripts for running the tool via Docker
- **Docker Support**: Two Dockerfiles - production (`Dockerfile`) and development (`Dockerfile.dev`)
- **Testing**: Simple diff-based testing in `test/` directory comparing outputs against expected results

## Development Workflow

1. The project uses containerized tools for consistency - most development tools (flake8, mypy, shellcheck, etc.) run inside Docker containers
2. All shell scripts and tools follow strict error handling (`set -Eeu -o pipefail`)

## File Structure

- **`tools/`**: Containerized development tool wrappers (flake8, mypy, shellcheck, shfmt, hadolint, uv)
- **`test/`**: Test suite with sample files, test scripts, and expected outputs
