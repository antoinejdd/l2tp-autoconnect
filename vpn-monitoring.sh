#!/usr/bin/env bash

###
# Default parameters and functions
# It defines logging and error handling
###

set -Eeuo pipefail
trap unexpected_error ERR
trap stopping_service SIGINT SIGTERM

unexpected_error() {
    trap - SIGINT SIGTERM ERR

    nmcli con down uuid "${VPN_UID}" 2>/dev/null \
    || true
    die "[Critical] An unexpected error occured"
}

msg() {
    echo >&2 -e "${1-}"
}

die() {
    local msg="${1}"
    local code="${2-1}"    # default exit status is 1
    msg "${msg}"
    exit "${code}"
}

stopping_service() {
    trap - SIGINT SIGTERM

    nmcli con down uuid "${VPN_UID}" 2>/dev/null \
    || true
    die "[Info] VPN monitoring service STOPPED!" 0
}

reconnect_vpn() {
    nmcli con down uuid "${VPN_UID}" 2>/dev/null \
    || true
    sleep 1s
    nmcli con up uuid "${VPN_UID}"
    sleep 1s
}

###
# Config
###

# Lookup the UUID of the VPN connection using the "nmcli con" command, copy the 36 character string listed and past it below:
VPN_UID='35c4008e-d2bd-4f8b-a923-a9852c80ba11'

# Delay in seconds
DELAY='30s'

# Check IP/Hostname
CHECK_HOST='1.1.1.1'

###
# Implementation
###

msg "[Info] VPN monitoring service STARTED!"

while true; do
    vpn_name="$(nmcli -g connection.id con show ${VPN_UID})"
    vpn_con_state=$(nmcli -g GENERAL.STATE con show ${VPN_UID})

    if [[ $vpn_con_state != "activated" ]]; then
        msg "[Info] Disconnected from ${vpn_name}, trying to reconnect..."
        reconnect_vpn
    else
        msg "[Info] Already connected to ${vpn_name}!"
    fi

    vpn_ip="$(nmcli -g ip4.address con show ${VPN_UID})"
    [[ -z $vpn_ip ]] \
    && msg "[Warning] No IPv4 address assigned to ${vpn_name} connection profile" \
    && continue

    vpn_dev="$(ip -br addr show to ${vpn_ip} | cut -d' ' -f1)"
    [[ -z $vpn_dev ]] \
    && msg "[Warning] Can not find netdev related to ${vpn_name} IPv4 address" \
    && continue

    if ping -c1 -W3 -I "${vpn_dev}" "${CHECK_HOST}" >/dev/null; then
        msg "[Info] Ping check (${CHECK_HOST}) - OK!"
    else
        msg "[Info] Ping check timeout (${CHECK_HOST}), trying to reconnect..."
        reconnect_vpn
    fi

    sleep "${DELAY}"
done
