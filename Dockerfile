FROM alpine:3.23.0

ENV S6_OVERLAY_VERSION="3.2.1.0"
# Without this a failing cont-init script is only logged, and samba comes up
# serving a default smb.conf with no shares and no users. Fail the container.
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2
LABEL maintainer="Alexander Chernov"

# apk --print-arch already uses s6-overlay's naming (x86_64, aarch64) and runs
# in the target-platform container, so a multi-arch build picks the matching
# archive without a mapping table. Hardcoding x86_64 here shipped an arm64
# image containing x86_64 binaries.
RUN apk add --no-cache curl && \
    S6_ARCH="$(apk --print-arch)" && \
    curl -L -o /tmp/s6-overlay-noarch.tar.xz "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz" && \
    curl -L -o /tmp/s6-overlay-arch.tar.xz "https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${S6_ARCH}.tar.xz" && \
    tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz && \
    tar -C / -Jxpf /tmp/s6-overlay-arch.tar.xz && \
    rm -f /tmp/s6-overlay-noarch.tar.xz /tmp/s6-overlay-arch.tar.xz

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