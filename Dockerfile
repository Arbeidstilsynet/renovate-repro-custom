FROM alpine:3.24.1@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b

# renovate: datasource=repology depName=alpine_3_23/gcc versioning=loose
ENV GCC_VERSION="9.4.0-r0"
# renovate: datasource=repology depName=alpine_3_23/musl-dev versioning=loose
ENV MUSL_DEV_VERSION="1.1.24-r8"

RUN apk add --no-cache \
    gcc="${GCC_VERSION}" \
    musl-dev="${MUSL_DEV_VERSION}"
