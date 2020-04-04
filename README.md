# stratux-pi4
Build a Stratux Europe on a Pi4B (Pi3B tested as well) based on a fresh Buster Lite Image

This started as a script just for myself to build a Stratux Europe, based on:
- https://github.com/b3nn0/stratux
- https://project-downloads.drogon.net/wiringpi-latest.deb
- http://download.glidernet.org/arm/rtlsdr-ogn-bin-ARM-latest.tgz
- https://osmocom.org/projects/rtl-sdr/
- Raspbian Buster Lite
- Raspberry Pi4B (also tested on Pi3B)

Steps required:
- fresh Raspbian Buster Lite Image with ssh enabled
- login as `pi` user
- sudo su
- cd ~/
- apt update
- apt full-upgrade
- apt install git -y
- git clone https://github.com/VirusPilot/stratux-pi4.git
- cd stratux-pi4
- run ./install.sh
- sudo reboot
- ...

Limitations/Modofications
- fancontrol service disabled
- selfupdate won't work
- commandline aliases not available (yet)
- Stratux Europe default settings modified for direct use with NMEA FLARM and SkyDemon

not implemented yet:
- WiFi AP
- https://github.com/steve-m/kalibrate-rtl
- flexible pathnames (currently hardcoded)
