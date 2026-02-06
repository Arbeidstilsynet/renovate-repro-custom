FROM alpine:3.12.0@sha256:a15790640a6690aa1730c38cf0a440e2aa44aaca9b0e8931a9f2b0d7cc90fd65

# renovate: datasource=repology depName=alpine_3_23/gcc versioning=loose
ENV GCC_VERSION="9.3.0-r2"
# renovate: datasource=repology depName=alpine_3_23/musl-dev versioning=loose
ENV MUSL_DEV_VERSION="1.1.24-r8"

RUN apk add --no-cache \
    gcc="${GCC_VERSION}" \
    musl-dev="${MUSL_DEV_VERSION}"
