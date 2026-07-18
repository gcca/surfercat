# syntax=docker/dockerfile:1.7

ARG ALPINE_VERSION=3.23
ARG DEPS_IMAGE=ghcr.io/gcca/surfercat-deps:latest
ARG DBMATE_IMAGE=ghcr.io/amacneil/dbmate:2.33.0

FROM ${DBMATE_IMAGE} AS dbmate

FROM ${DEPS_IMAGE} AS deps

FROM deps AS build

WORKDIR /src

COPY project.linux.json ./project.json
COPY protos ./protos
COPY c ./c
COPY src ./src

RUN protoc \
        -I protos \
        -I /usr/include \
        --cpp_out=c \
        --grpc_out=c \
        --plugin=protoc-gen-grpc="$(which grpc_cpp_plugin)" \
        protos/session.proto

RUN c3c build surfercat \
    && test -x build/surfercat

FROM alpine:${ALPINE_VERSION} AS execute

RUN apk add --no-cache \
    c-ares \
    ca-certificates \
    grpc-cpp \
    libstdc++ \
    openssl \
    protobuf \
    re2 \
    sqlite \
    sqlite-libs \
    zlib \
    zstd-libs

WORKDIR /app

COPY --from=dbmate /usr/local/bin/dbmate /usr/local/bin/dbmate
COPY --from=build /src/build/surfercat /usr/local/bin/surfercat
COPY db/migrations/*.sql /app/migrations/
COPY docker-entrypoint.sh /usr/local/bin/surfercat-entrypoint

RUN chmod +x /usr/local/bin/surfercat-entrypoint \
    && mkdir -p /app/data

ENV TZ=UTC \
    DB_URL=/app/data/surfercat.db \
    PORT=8000 \
    SESSION_TARGET=purrboss:50051

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -qO- "http://127.0.0.1:${PORT}/surfercat/healthcheck" >/dev/null || exit 1

ENTRYPOINT ["surfercat-entrypoint"]
