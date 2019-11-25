#!/usr/bin/env sh

set -e

is_enable() {

    local v="$(echo ${1} | tr '[:upper:]' '[:lower:]')"

    if [ "${v}" = 0 ] || [ -z "${v}" ] || [ "${v}" = "false" ]; then
        false
    else
        true
    fi

}

is_number() {

    local re='^[0-9]+$'

    if ! [[ ${1} =~ ${re} ]] ; then
        true
    else
        false
    fi
}

args_password() {

    local password="${PASSWORD}"
    local args="-k ${password}"

    if [ -z "${password}" ] || [ ${#password} -lt 12 ] ; then
        args="-k $(hostname)"
    fi

    echo "${args}"
}

args_encrypt_method() {

    local method="${METHOD}"
    local args="-m ${method}"

    local allowed_methods="aes-128-gcm aes-192-gcm aes-256-gcm chacha20-ietf-poly1305 xchacha20-ietf-poly1305"
    local is_allowed=""

    for i in ${allowed_methods}
    do
        if [ "${method}" = ${i} ]; then
            is_allowed="1"
        fi
    done

    if [ -z "${is_allowed}" ]; then
        args="-m aes-128-gcm"
    fi

    echo "${args}"
}

args_timeout() {

    local timeout="${TIMEOUT}"
    local args="-t 60"
    if [ $(is_number ${timeout}) ]; then
        if [ ${timeout} -gt 0 ] && [ ${timeout} -lt 600 ]; then
            args="-t ${timeout}"
        fi
    fi
    echo "${args}"
}

args_tcp_udp_relay() {

    local args="-u"

    if [ $(is_enable ${UDP_RELAY}) ]; then
        if [ ! $(is_enable ${TCP_RELAY}) ]; then
            local args="-U"
        fi
    else
        args=""
    fi

    echo "${args}"
}

args_ipv6_first() {

    local args=""

    if [ $(is_enable ${IPV6_FIRST}) ];then
        args="-6"
    fi

    echo "${args}"
}

args_dns_addrs() {

    local dns_addrs="${DNS_ADDRS}"
    local args=""

    if [ ! -z "${dns_addrs}" ]; then
        args="-d ${dns_addrs}"
    fi

    echo "${args}"
}

args_tcp_fast_open() {

    local args="--fast-open"

    if [ ! $(is_enable ${TCP_FAST_OPEN}) ]; then
        args=""
    fi

    echo "${args}"
}

args_port_reuse() {

    local args=""

    if [ $(is_enable ${PORT_REUSE}) ]; then
        args="--reuse-port"
    fi

    echo "${args}"
}

args_tcp_no_delay() {

    local args="--no-delay"

    if [ ! $(is_enable ${TCP_NODELAY}) ]; then
        args=""
    fi

    echo "${args}"
}

args_mtu() {

    local mtu="${MTU}"
    local args=""

    if [ $(is_number ${mtu}) ];then
        args="--mtu ${mtu}"
    fi

    echo "${args}"
}

args_tcp_multi_path() {

    local args="--mptcp"

    if [ ! $(is_enable ${TCP_MULTIPATH}) ]; then
        args=""
    fi

    echo "${args}"
}

args_v2ray_plugin() {

    local v2ray_plugin_opts="${V2RAY_PLUGIN_OPTS}"
    local args=""

    if [ ! -z "${v2ray_plugin_opts}" ]; then
        args="--plugin v2ray-plugin --plugin-opts ${v2ray_plugin_opts}"
    fi

    echo "${args}"
}

args_verbose_mode(){

    local args=""

    if [ $(is_enable ${VERBOSE_MODE}) ];then
        args="-v"
    fi

    echo "${args}"
}

parser_args() {

    local server="-s 0.0.0.0"
    local port="-p 80"
    local password="$(args_password)"
    local encrypt_method="$(args_encrypt_method)"
    local timeout="$(args_timeout)"
    local tcp_udp_relay="$(args_tcp_udp_relay)"
    local ipv6_first="$(args_ipv6_first)"
    local tcp_fast_open="$(args_tcp_fast_open)"
    local port_reuse="$(args_port_reuse)"
    local tcp_no_delay="$(args_tcp_no_delay)"
    local mtu="$(args_mtu)"
    local tcp_multi_path="$(args_tcp_multi_path)"
    local v2ray_plugin_opts="$(args_v2ray_plugin)"

    local args="${server} ${port} ${password} ${encrypt_method} ${timeout} ${tcp_udp_relay} ${ipv6_first} ${tcp_fast_open} ${port_reuse} ${tcp_no_delay} ${mtu} ${tcp_multi_path} ${v2ray_plugin_opts}"

    echo ${args}
}

start_ss_server() {
    echo -e "start ss-server with args:\n${@}"
    exec ss-server ${@}
}

main() {

    if [ ${1} = "ss-server" ] && [ ${#} = 1 ];then
        start_ss_server $(parser_args)
    else
        exec ${@}
    fi
}

main "$@"
