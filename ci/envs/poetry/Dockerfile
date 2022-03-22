ARG PYTHON_VERSION=3.10

ARG POETRY_VERSION=1.1.13

FROM --platform=linux/amd64 python:${PYTHON_VERSION}

ENV PYTHONPATH=${PYTHONPATH}:${PWD}

RUN apt-get update && \
    apt-get install -y jq &&  \
    pip3 install poetry==1.1.13

RUN poetry config virtualenvs.create false