FROM alpine:3.24.2@sha256:294b683cb724975bec92580e1e685676bd4b50bda910ddb8c51d4cabeaec77e6

# renovate: datasource=repology depName=alpine_3_23/gcc versioning=loose
ENV GCC_VERSION="9.4.0-r0"
# renovate: datasource=repology depName=alpine_3_23/musl-dev versioning=loose
ENV MUSL_DEV_VERSION="1.1.24-r8"

RUN apk add --no-cache \
    gcc="${GCC_VERSION}" \
    musl-dev="${MUSL_DEV_VERSION}"
