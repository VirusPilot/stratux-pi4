#!/bin/bash

systemctl disable dhcpcd
systemctl unmask hostapd
systemctl enable hostapd
systemctl enable dnsmasq
cp wlan0 /etc/network/interfaces.d/
reboot
