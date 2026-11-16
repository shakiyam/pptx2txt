FROM python:3.15-slim-trixie
# TODO: Remove package upgrades once base image includes zlib1g >= 1:1.3.dfsg+really1.3.1-1+deb13u1 (CVE-2026-76844, CVE-2026-85091)
# hadolint ignore=DL3008
RUN apt-get update \
  && apt-get -y --no-install-recommends --only-upgrade install zlib1g \
  && rm -rf /var/lib/apt/lists/*
WORKDIR /opt/pptx2txt
# Sync into the system Python so the ENTRYPOINT's python3 imports the dependencies without a venv
ENV UV_PROJECT_ENVIRONMENT=/usr/local
COPY pyproject.toml uv.lock ./
# pip comes from the base image and is unused at runtime; removing it clears trivy findings in its bundled libraries
# (uv sync leaves it in place even though uv.lock does not list it, and uninstalling it leaves the base image's pip -> pip3 symlink dangling)
RUN --mount=from=ghcr.io/astral-sh/uv:0.13,source=/uv,target=/bin/uv \
  uv sync --locked --no-cache \
  && uv pip uninstall --system pip \
  && rm -f /usr/local/bin/pip
COPY pptx2txt.py .
WORKDIR /work
ARG SOURCE_COMMIT
LABEL org.opencontainers.image.revision=$SOURCE_COMMIT
ENTRYPOINT ["python3", "/opt/pptx2txt/pptx2txt.py"]
