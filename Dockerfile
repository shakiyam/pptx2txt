FROM ghcr.io/oracle/oraclelinux:9-slim
# hadolint ignore=DL3041
RUN microdnf -y install python3.12 python3.12-pip \
  && microdnf clean all \
  && rm -rf /var/cache
COPY requirements.txt /requirements.txt
# hadolint ignore=DL3013
RUN python3.12 -m pip install --no-cache-dir --upgrade pip && python3.12 -m pip install --no-cache-dir -r /requirements.txt
COPY pptx2txt.py /pptx2txt.py
WORKDIR /work
ARG SOURCE_COMMIT
ENV SOURCE_COMMIT=$SOURCE_COMMIT
ENTRYPOINT ["python3.12", "/pptx2txt.py"]
