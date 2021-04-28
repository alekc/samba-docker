FROM alpine:3.13.5 AS s6-alpine
LABEL maintainer="Alexander Chernov"

ARG S6_OVERLAY_RELEASE=https://github.com/just-containers/s6-overlay/releases/latest/download/s6-overlay-amd64.tar.gz
ENV S6_OVERLAY_RELEASE=${S6_OVERLAY_RELEASE}

ADD rootfs /

# s6 overlay Download
ADD ${S6_OVERLAY_RELEASE} /tmp/s6overlay.tar.gz

# Build and some of image configuration
RUN apk upgrade --update --no-cache \
    && rm -rf /var/cache/apk/* \
    && tar xzf /tmp/s6overlay.tar.gz -C / \
    && rm /tmp/s6overlay.tar.gz

# Init
ENTRYPOINT [ "/init" ]

FROM s6-alpine

RUN apk add --no-cache \
    samba-common-tools \
    samba-client \
    samba-server \
    python3 py3-jinja2 py3-yaml

EXPOSE 445/tcp
