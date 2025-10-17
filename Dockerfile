FROM python:3.14-slim-bookworm
COPY --from=ghcr.io/astral-sh/uv:0.9.2 /uv /bin/uv
COPY requirements.txt /requirements.txt
RUN uv pip install --system --no-cache-dir -r /requirements.txt
COPY pptx2txt.py /pptx2txt.py
WORKDIR /work
ARG SOURCE_COMMIT
ENV SOURCE_COMMIT=$SOURCE_COMMIT
ENTRYPOINT ["python3", "/pptx2txt.py"]
