# For available Chromium versions in the distro, see https://repology.org/project/chromium/versions
# Chromium versions changes should be matched with Puppeteer version from https://pptr.dev/supported-browsers
ARG CHROMIUM_VERSION="143.*"

FROM node:24-slim@sha256:4660b1ca8b28d6d1906fd644abe34b2ed81d15434d26d845ef0aced307cf4b6f AS base
FROM base AS builder

RUN npm i -g corepack@latest && corepack enable

WORKDIR /app

COPY .npmrc package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY packages ./packages
# don't copy api code for better caching
COPY apps/api/package.json ./apps/api/
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile

COPY apps/api ./apps/api
RUN pnpm --filter api build


FROM base AS runner
ARG CHROMIUM_VERSION

### Versions managed by Renovate
### https://dev.azure.com/Atil-utvikling/Produkter%20og%20tjenester/_git/infra-renovate?anchor=custom-managers
# renovate: datasource=repology depName=debian_12/fontconfig versioning=loose
ENV FONTCONFIG_VERSION="2.14.1-4"
# renovate: datasource=repology depName=debian_12_backports/curl versioning=loose
ENV CURL_VERSION="8.14.1-2~bpo12+1"

# Install specific Chromium version and other dependencies
RUN echo "deb http://security.debian.org/debian-security bookworm-security main" > /etc/apt/sources.list.d/security.list \
    && echo "deb http://deb.debian.org/debian bookworm-backports main" > /etc/apt/sources.list.d/backports.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends chromium-common=${CHROMIUM_VERSION} chromium=${CHROMIUM_VERSION} \
    && apt-get install -y --no-install-recommends fontconfig=${FONTCONFIG_VERSION} \
    && apt-get install -y --no-install-recommends -t bookworm-backports curl=${CURL_VERSION} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create directory for custom fonts
RUN mkdir -p /usr/share/fonts/truetype/custom
COPY apps/api/fonts/*.ttf /usr/share/fonts/truetype/custom/
RUN fc-cache -fv

ENV NODE_ENV=production
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
ENV XDG_CONFIG_HOME=/tmp/.chromium
ENV XDG_CACHE_HOME=/tmp/.chromium

WORKDIR /app

COPY --from=builder /app/apps/api/dist ./dist
# for trivy scanning purposes (dependency-track)
COPY --from=builder /app/apps/api/package.json ./
COPY --from=builder /app/pnpm-lock.yaml ./

# Copy static assets for @fastify/swagger-ui (which is external)
COPY --from=builder /app/node_modules/@fastify/swagger-ui/static ./static
COPY --from=builder /app/node_modules/@fastify/swagger-ui/static/logo.svg ./dist/static/logo.svg


EXPOSE 4000

HEALTHCHECK --interval=30s --timeout=10s CMD curl -f http://localhost:4000/health || exit 1

CMD ["node", "dist/server.cjs"]
