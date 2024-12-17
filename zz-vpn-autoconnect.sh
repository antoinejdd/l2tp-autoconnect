#!/bin/sh

LAN_IF='end0'

if [ "$1" = "${LAN_IF}" ]; then
    case "$2" in
        up)
            systemctl start vpn-monitoring.service
            ;;
        down)
            systemctl stop vpn-monitoring.service
            ;;
    esac
elif [ "$(nmcli -g GENERAL.STATE device show ${LAN_IF})" = "20 (unavailable)" ]; then
    systemctl stop vpn-monitoring.service
fi
