FROM alpine:latest

RUN apk add --no-cache \
    samba-common-tools \
    samba-client \
    samba-server

ADD init.sh /init.sh
RUN chmod +x /init.sh

EXPOSE 445/tcp

CMD ["/init.sh"]
