FROM alpine:3.23.0

ENV S6_OVERLAY_VERSION="3.2.1.0"
LABEL maintainer="Alexander Chernov"

RUN apk add --no-cache curl && \
    curl -L -o /tmp/s6-overlay-noarch.tar.xz "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" && \
    curl -L -o /tmp/s6-overlay-x86_64.tar.xz "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz" && \
    tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz && \
    tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz && \
    rm -f /tmp/s6-overlay-noarch.tar.xz /tmp/s6-overlay-x86_64.tar.xz

RUN apk add --no-cache \
    samba-common-tools=4.22.10-r0 \
    samba-client=4.22.10-r0 \
    samba-server=4.22.10-r0 \
    python3=3.12.14-r0 \
    py3-jinja2=3.1.6-r0 \
    py3-yaml=6.0.3-r0

ADD rootfs /

EXPOSE 445/tcp

# Init
ENTRYPOINT ["/init"]