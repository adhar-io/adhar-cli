# syntax = docker/dockerfile:experimental
FROM --platform=$BUILDPLATFORM golang:1.16-alpine as builder
LABEL maintainer="Tapas Jena <tapas.jena@anitechcs.com>"

ENV CGO_ENABLED 0

ARG VERSION=dev
ARG COMMIT=none
ARG DATE=unknown
ARG REPOSITORY=unknown

WORKDIR /app

RUN --mount=type=bind,target=/cache,from=adhar-io/adhar-cli-build-cache \
    mkdir -p /go/pkg/ && cp -R /cache/mod/ /go/pkg/ || true && \
    mkdir -p /root/.cache/ && cp -R /cache/go-build/ /root/.cache/ || true

COPY . .

RUN go generate ./...
RUN go test ./...

FROM scratch as build-cache
LABEL maintainer="Tapas Jena <tapas.jena@anitechcs.com>"

COPY --from=builder /go/pkg/mod /mod
COPY --from=builder /root/.cache/go-build /go-build

FROM builder as build-image

ARG TARGETOS
ARG TARGETARCH

ENV GOOS=${TARGETOS} GOARCH=${TARGETARCH}

RUN go build -o /go/bin/app -ldflags="-s -w -X github.com/${REPOSITORY}/cmd.Version=${VERSION} -X github.com/${REPOSITORY}/cmd.Commit=${COMMIT} -X github.com/${REPOSITORY}/cmd.Date=${DATE}"

FROM scratch as release
LABEL maintainer="Tapas Jena <tapas.jena@anitechcs.com>"

WORKDIR /app

COPY --from=build-image /app/deploy/ /app/deploy/
COPY --from=build-image /app/README* /app/LICENSE* /app/
COPY --from=build-image /go/bin/ /app/

ENTRYPOINT ["/app/app"]
