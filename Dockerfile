# syntax=docker/dockerfile:1
FROM alpine:3.19.1
RUN apk add --no-cache \
    bash \
    curl \
    jq

WORKDIR /star_gazer
COPY star_gazer.sh .
RUN chmod +x star_gazer.sh

ENTRYPOINT ["/star_gazer/star_gazer.sh"]
