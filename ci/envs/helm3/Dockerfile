ARG HELM_VERSION=3.10

FROM --platform=linux/amd64 debian:jessie-slim

RUN apt-get update && apt-get install -y curl unzip git

RUN curl https://baltocdn.com/helm/signing.asc | apt-key add - && apt-get install apt-transport-https --yes && \
    echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list && \
    apt-get update && apt-get install helm

RUN helm plugin install https://github.com/datreeio/helm-datree