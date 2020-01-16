# syntax = docker.io/docker/dockerfile:1.1.3-experimental

# target: cue-builder
ARG GOLANG_VERSION
ARG ALPINE_VERSION
FROM docker.io/golang:${GOLANG_VERSION}-alpine${ALPINE_VERSION} AS cue-builder
ENV OUTDIR='/out' \
	GO111MODULE='on'
RUN set -eux && \
	apk add --no-cache \
		ca-certificates \
		git
RUN set -eux && \
	CGO_ENABLED=0 GOBIN=${OUTDIR}/usr/bin/ go get -a -u -v -tags='osusergo,netgo,static' -installsuffix='netgo' -ldflags='-d -s -w "-extldflags=-fno-PIC -static"' \
		cuelang.org/go/cmd/cue@master

# target: cue
FROM gcr.io/distroless/static:latest AS cue
COPY --from=cue-builder /out/ /
ENTRYPOINT ["/usr/bin/cue"]

# target: cue-debug
FROM gcr.io/distroless/base:debug-nonroot AS cue-debug
COPY --from=cue-builder /out/ /
ENTRYPOINT ["/usr/bin/cue"]
