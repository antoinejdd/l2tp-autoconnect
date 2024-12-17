# l2tp-autoconnect

## Locations

- vpn-l2tp.nmconnection: `/etc/NetworkManager/system-connections/vpn-l2tp.nmconnection`
- vpn-monitoring.sh: `/usr/local/bin/vpn-monitoring.sh`
- vpn-monitoring.service: `/etc/systemd/system/vpn-monitoring.service`
- zz-vpn-autoconnect.sh: `/etc/NetworkManager/dispatcher.d/zz-vpn-autoconnect.sh`

## Setup

1. Install files to their respective location
1. Replace `<VALUES>` with actual ones
1. Execute this commands as root:

```sh
chmod 600 /etc/NetworkManager/system-connections/vpn-l2tp.nmconnection
chmod a+rx /usr/local/bin/vpn-monitoring.sh
systemctl daemon-reload
chmod a+rx /etc/NetworkManager/dispatcher.d/zz-vpn-autoconnect.sh
```
