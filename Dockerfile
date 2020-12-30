FROM alpine:3.12.3

RUN apk add --no-cache \
    samba-common-tools \
    samba-client \
    samba-server

ADD k8s.sh /k8s.sh

EXPOSE 445/tcp

CMD ["/k8s.sh"]
