# Creating a python base with shared environment variables
FROM python:3.10-slim as python-base

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=off \
    PIP_DISABLE_PIP_VERSION_CHECK=on \
    PIP_DEFAULT_TIMEOUT=100 \
    POETRY_HOME="/opt/poetry" \
    POETRY_VIRTUALENVS_IN_PROJECT=true \
    POETRY_NO_INTERACTION=1 \
    PYSETUP_PATH="/opt/pysetup" \
    VENV_PATH="/opt/pysetup/.venv"

ENV PATH="$POETRY_HOME/bin:$VENV_PATH/bin:$PATH"

# builder-base is used to build dependencies
FROM python-base as builder-base

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        curl \
        build-essential

# Install Poetry - respects $POETRY_VERSION & $POETRY_HOME
ENV POETRY_VERSION=1.1.13
RUN curl -sSL https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py | python

# We copy our Python requirements here to cache them
# and install only runtime deps using poetry
WORKDIR ${PYSETUP_PATH}

COPY ./poetry.lock ./pyproject.toml ./

ARG int_artifactory_url=https://localhost/artifactory
ARG int_artifactory_user=admin
ARG int_artifactory_apikey=password
ARG int_artifactory_py_repo_key=python
ARG release_type=patch

RUN poetry config http-basic.artifactory ${int_artifactory_user} ${int_artifactory_apikey} && \
	poetry config repositories.artifactory ${int_artifactory_url}/api/pypi/${int_artifactory_py_repo_key} && \
	poetry version ${release_type} && \
	poetry install --no-dev

# 'production' stage uses the clean 'python-base' stage and copyies
# in only our runtime deps that were installed in the 'builder-base'
FROM python-base as production

ENV FASTAPI_ENV=production

COPY --from=builder-base ${VENV_PATH} ${VENV_PATH}

COPY ./app /app

WORKDIR /app

ARG app_version="N/A"
ARG app_revision="N/A"

RUN echo ${app_version} > .version && echo ${app_revision} > .revision

CMD ["uvicorn", "--reload", "--host=0.0.0.0", "--port=3000", "main:app"]