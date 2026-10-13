# TODO

1. Move to Python 3.15 once `ghcr.io/astral-sh/uv` publishes a `python3.15-trixie-slim` tag (not available as of 2026-10-13). `make check_for_image_updates` reports that `python:3.14-slim-trixie` differs from `python:slim` (now Python 3.15.0); `python:3.15-slim-trixie` exists and both requirements files install from wheels on it. Update the base image in `Dockerfile` and `Dockerfile.dev`, the uv image tag in `tools/uv.sh`, and the comparison tags in `Makefile` together.
