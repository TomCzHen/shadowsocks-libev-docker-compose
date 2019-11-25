#!/usr/bin/env sh
set -e

export CADDY_ROOT="/root/caddy"
export CADDYPATH="${CADDY_ROOT}/assets"
export CADDY_WWW_ROOT="${CADDY_ROOT}/www"
export CADDY_LOG_ROOT="${CADDY_ROOT}/logs"

mkdir -p ${CADDY_WWW_ROOT}/${CADDY_DOMAIN}

parser_args() {

    local args="-agree -conf /etc/caddy/Caddyfile --log stdout"

}

start_caddy() {
    exec caddy ${@}
}

main() {

    if [ ${1} = "caddy" ] && [ ${#} = 1 ];then
        start_caddy $(parser_args)
    else
        exec ${@}
    fi
}

main "$@"