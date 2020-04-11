# stratux-pi4
Build a Stratux Europe on a Pi4B (Pi3B tested as well) based on a fresh Raspbian Buster Lite image

This started as a script just for myself to build a Stratux Europe for a passive cooled Pi4B, based on:
- https://github.com/b3nn0/stratux
- https://project-downloads.drogon.net/wiringpi-latest.deb (only v2.52 works with Pi4B)
- http://download.glidernet.org/arm/rtlsdr-ogn-bin-ARM-latest.tgz (only ARM version works with Pi4B)
- https://github.com/Determinant/dump1090-fa-stratux (based on dump1090-fa)
- https://osmocom.org/projects/rtl-sdr/ (apt version used for dump1090-fa)
- Raspbian Buster Lite
- Raspberry Pi4B (also tested on Pi3B)

## Steps required:
- Pi4B connected to LAN
- boot from a fresh Raspbian Buster Lite Image with ssh enabled
- login as `pi` user
```
sudo su
cd ~/
apt update
apt full-upgrade
apt install git -y
git clone https://github.com/VirusPilot/stratux-pi4.git
cd stratux-pi4
./install.sh (press y a couple of times)
```

- after reboot please reconnect LAN and/or WiFi and Stratux should work right away

## Limitations/Modifications
- Network configuration: dnsmasq instead of isc-dhcp-server
- Settings Page: WiFi configuration is not working !! (contributions to change that are welcome)
- WiFi IP: 192.168.1.1 (required for FLARM NMEA and SkyDemon)
- WiFi SSID: stratux-pi4
- WiFi Password: stratux-pi4
- fancontrol service disabled
- selfupdate won't work
- commandline aliases not available
- BladeRF 2.0 Micro support disabled
- https://github.com/steve-m/kalibrate-rtl not installed

## not yet implemented/added:
- flexible pathnames (currently hardcoded)
- as soon as https://github.com/flightaware/dump1090/pull/61 is accepted, switch to https://github.com/flightaware/dump1090
