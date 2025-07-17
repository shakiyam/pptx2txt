FROM ghcr.io/oracle/oraclelinux:9-slim
COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv
# hadolint ignore=DL3041
RUN microdnf -y install python3.12 \
  && microdnf clean all \
  && rm -rf /var/cache
COPY requirements.txt /requirements.txt
RUN uv pip install --system --no-cache-dir -r /requirements.txt
COPY pptx2txt.py /pptx2txt.py
WORKDIR /work
ARG SOURCE_COMMIT
ENV SOURCE_COMMIT=$SOURCE_COMMIT
ENTRYPOINT ["python3.12", "/pptx2txt.py"]
