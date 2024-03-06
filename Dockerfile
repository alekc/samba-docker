FROM alpine:edge

ENV S6_OVERLAY_VERSION="3.1.6.2"
LABEL maintainer="Alexander Chernov"

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

RUN apk add --no-cache \
    samba-common-tools \
    samba-client \
    samba-server \
    python3 py3-jinja2 py3-yaml py-pip

ADD rootfs /

EXPOSE 445/tcp

# Init
ENTRYPOINT ["/init"]