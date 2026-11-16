FROM python:3.15-slim-trixie
WORKDIR /opt/pptx2txt
# Sync into the system Python so the tools stay on the default PATH without a venv
ENV UV_PROJECT_ENVIRONMENT=/usr/local
COPY pyproject.toml uv.lock ./
RUN --mount=from=ghcr.io/astral-sh/uv:0.13,source=/uv,target=/bin/uv \
  uv sync --locked --no-cache --extra dev
COPY pptx2txt.py .
WORKDIR /work
ENV HOME=/tmp
ARG SOURCE_COMMIT
LABEL org.opencontainers.image.revision=$SOURCE_COMMIT
CMD ["/bin/bash"]
