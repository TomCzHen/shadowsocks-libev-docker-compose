FROM golang:alpine as v2ray-plugin-builder

ARG v2ray_plugin_version="1.1.0"
ENV GO111MODULE on

RUN apk add --no-cache git curl tar ca-certificates

RUN mkdir -p /tmp/v2ray-plugin && \
    curl -L https://github.com/shadowsocks/v2ray-plugin/archive/v${v2ray_plugin_version}.tar.gz | tar xz -C /tmp/v2ray-plugin --strip-components 1

WORKDIR /tmp/v2ray-plugin

RUN go get -d && go build

ARG shadowsocks_libev_version="3.3.3"
FROM shadowsocks/shadowsocks-libev:v${shadowsocks_libev_version}

ENV PASSWORD="" \
    METHOD="aes-256-gcm" \
    TIMEOUT="300" \
    UDP_RELAY=1 \
    TCP_RELAY=1 \
    TCP_NODELAY=0 \
    TCP_FAST_OPEN=0 \
    TCP_MULTIPATH=0 \
    IPV6_FIRST=0 \
    PORT_REUSE=0 \
    DNS_ADDRS="8.8.8.8,8.8.4.4" \
    V2RAY_PLUGIN_OPTS="server" \
    VERBOSE_MODE=0

COPY --from=v2ray-plugin-builder ["/tmp/v2ray-plugin/v2ray-plugin","/usr/local/bin/"]
COPY --chown=nobody:nobody ["docker-entrypoint.sh","/usr/local/bin/"]

RUN chmod +x /usr/local/bin/docker-entrypoint.sh 
# && apk add --no-cache rng-tools c-ares libev mbedtls pcre libsodium

USER nobody
EXPOSE 8388
ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["ss-server"]