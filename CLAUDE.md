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

#### Dependencies Management Details

The project uses `uv` for dependency management with a two-file approach:

- **Input files** (`*.in`): Human-maintained files listing direct dependencies
  - `requirements.in` - Production dependencies (only python-pptx)
  - `requirements_dev.in` - Development dependencies (linters, type checkers, etc.)

- **Output files** (`*.txt`): Auto-generated files with pinned versions
  - `requirements.txt` - Generated from requirements.in with exact versions
  - `requirements_dev.txt` - Generated from requirements_dev.in with exact versions

When updating dependencies:
1. Edit the `.in` file to add/remove/update dependencies
2. Run `make update_requirements` or `make update_requirements_dev` to regenerate the `.txt` files
3. The generated `.txt` files include all transitive dependencies with exact versions for reproducible builds

## Architecture Notes

- **Main Script**: `pptx2txt.py` - Core conversion logic using python-pptx library
- **Shell Wrappers**: `pptx2txt` (production) and `pptx2txt_dev` (development) - Convenient wrapper scripts for running the tool via Docker
- **Docker Support**: Two Dockerfiles - production (`Dockerfile`) and development (`Dockerfile.dev`)
- **Testing**: Simple diff-based testing in `test/` directory comparing outputs against expected results
- **Dependencies**: Managed via uv with separate production and development requirements files

## Development Workflow

1. The project uses containerized tools for consistency - most development tools (flake8, mypy, shellcheck, etc.) run inside Docker containers
2. All shell scripts and tools follow strict error handling (`set -eu -o pipefail`)
3. Tests use simple file comparison - generate output and compare against expected files in `test/expected/`

## File Structure

- **`tools/`**: Contains containerized development tool wrappers
  - Shell scripts that run linters and tools inside Docker containers
  - Ensures consistent development environment across platforms
- **`test/`**: Test suite directory
  - `sample*.pptx`: Valid test input files
  - `invalid.pptx`: Intentionally corrupted file for error testing
  - `write_test.pptx`: File for testing write permission errors
  - `expected/`: Directory containing expected output files for comparison
  - `test_basic.sh`: Basic functionality tests using diff
  - `test_error_scenarios.sh`: Comprehensive error handling tests
  - `clean.sh`: Cleanup script that removes test artifacts between test runs