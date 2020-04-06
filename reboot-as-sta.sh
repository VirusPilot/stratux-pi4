#!/bin/bash

systemctl disable hostapd
systemctl disable dnsmasq
systemctl enable dhcpcd
rm -f /etc/network/interfaces.d/wlan0
reboot
