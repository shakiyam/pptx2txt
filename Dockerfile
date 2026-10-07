FROM python:3.14-slim-trixie
COPY requirements.txt /requirements.txt
RUN --mount=from=ghcr.io/astral-sh/uv:0.12,source=/uv,target=/bin/uv \
  uv pip install --system --no-cache-dir -r /requirements.txt
COPY pptx2txt.py /pptx2txt.py
WORKDIR /work
ARG SOURCE_COMMIT
ENV SOURCE_COMMIT=$SOURCE_COMMIT
ENTRYPOINT ["python3", "/pptx2txt.py"]
