FROM python:3.10-slim-bullseye
COPY requirements.txt /requirements.txt
RUN pip install --no-cache-dir -r /requirements.txt
COPY pptx2txt.py /pptx2txt.py
WORKDIR /work
ENTRYPOINT ["python", "/pptx2txt.py"]
