FROM alpine:latest

RUN apk add --no-cache \
    samba-common-tools \
    samba-client \
    samba-server \
    python3 py3-jinja2 py3-yaml

ADD init.sh /init.sh
RUN chmod +x /init.sh

ADD config /etc/config-gen

EXPOSE 445/tcp

CMD ["/init.sh"]
