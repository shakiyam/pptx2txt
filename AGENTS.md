# AGENTS.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

pptx2txt is a Python tool that converts PowerPoint `.pptx` files to text format. It extracts text from slides including regular text, tables, and grouped shapes.

## Key Commands

### Initial Setup

```bash
# Install git hooks (run once after cloning)
make hooks
```

This installs a pre-commit hook that automatically updates the version number in `pptx2txt.py` to the current date (YYYY-MM-DD format) whenever `pptx2txt.py` is modified and committed.

### Building and Testing

```bash
# Run all checks (see `make help` for what it includes)
make all

# Run all tests (both basic and error scenarios)
make test

# Run individual test suites:
./test/test_basic.sh        # Basic functionality tests
./test/test_error_scenarios.sh  # Error handling tests
```

### Formatting, Linting, and Type Checking

```bash
# Run all formatters (rewrites files in place)
make format

# Run all linters
make lint

# Run Python type checking
make mypy

# List all targets, including individual formatters and linters
make help
```

### Building Docker Images

```bash
# Build production image
make build

# Build development image (includes dev dependencies)
make build_dev
```

When `make trivy` reports vulnerabilities whose fixed versions the distribution already ships, run `NO_CACHE=1 make trivy` to rebuild the cached layers that still hold the old packages.

### Updating Dependencies

```bash
# Update uv.lock and export requirements.txt from it
make update_uv_lock
```

The project uses `uv` to manage dependencies. Edit `pyproject.toml` to add/remove dependencies, then run the make command above to regenerate `uv.lock` and `requirements.txt` with pinned versions.

## Architecture Notes

- **Main Script**: `pptx2txt.py` - Core conversion logic using python-pptx library
- **Shell Wrappers**: `pptx2txt` (production) and `pptx2txt_dev` (development) - Convenient wrapper scripts for running the tool via Docker; `pptx2txt` is self-contained so it can be copied and used on its own, and must not source `tools/`
- **Docker Support**: Two Dockerfiles - production (`Dockerfile`) and development (`dev.Dockerfile`)
- **Testing**: Shell scripts in `test/` run the production image through the `pptx2txt` wrapper; `test_basic.sh` compares the converted text with `test/expected/`, and `test_error_scenarios.sh` checks exit codes and messages of error cases. `test_basic.bat` runs the basic test on Windows with the host Python

## Development Workflow

1. The project uses containerized tools for consistency - most development tools (ruff, mypy, shellcheck, etc.) run inside Docker containers
2. When running Python code for testing or verification, always use `./pptx2txt_dev python3` instead of the host's `python3` to ensure correct dependencies and environment
3. All shell scripts and tools follow strict error handling (`set -Eeu -o pipefail`)

## File Structure

- **`tools/`**: Containerized development tool wrappers invoked by Makefile targets (see `make help`)
- **`test/`**: Test suite with sample files, test scripts, and expected outputs

## Decisions

- **Dependencies pinned in `uv.lock`**: The container images install from `uv.lock`, and local installs without containers (see README) install from `requirements.txt` exported from it, so every environment runs the tested versions. Runtime and development dependencies are resolved together, so a development tool may constrain a runtime version; this is accepted as keeping the tested and shipped versions identical
- **Exported `requirements.txt` committed**: Windows users install with pip through `setup.bat` instead of uv, because the SendTo shortcut records the interpreter path and a system Python is less likely to disappear from under it than the uv-managed Python behind a project venv; the exported file gives them the pinned versions without uv
- **Development dependencies as an extra**: `dev` stays in `[project.optional-dependencies]` rather than `[dependency-groups]`, because `uv sync` installs the `dev` group by default but not extras, so a plain `uv sync` installs only what the application needs
- **No platform restriction in `uv.lock`**: `[tool.uv] environments` is left unset because narrowing it drops only wheels, not packages, while making installs fail on unlisted platforms; revisit if the daily update check keeps reporting lock changes caused only by platforms nobody uses
- **System Python in images**: The Dockerfiles run `uv sync` with `UV_PROJECT_ENVIRONMENT=/usr/local` instead of creating a venv, so the installed commands stay on the default `PATH`
