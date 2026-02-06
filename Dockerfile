FROM alpine:3.23.3@sha256:25109184c71bdad752c8312a8623239686a9a2071e8825f20acb8f2198c3f659

# renovate: datasource=repology depName=alpine_3_23/gcc versioning=loose
ENV GCC_VERSION="9.3.0-r2"
# renovate: datasource=repology depName=alpine_3_23/musl-dev versioning=loose
ENV MUSL_DEV_VERSION="1.1.24-r8"

RUN apk add --no-cache \
    gcc="${GCC_VERSION}" \
    musl-dev="${MUSL_DEV_VERSION}"
