# stratux-pi4
Build a Stratux Europe on a Pi4B (Pi3B tested as well) based on a fresh Buster Lite Image

This started as a script just for myself to build a Stratux Europe, based on:
- https://github.com/b3nn0/stratux
- https://project-downloads.drogon.net/wiringpi-latest.deb (only v2.52 works with Pi4B)
- http://download.glidernet.org/arm/rtlsdr-ogn-bin-ARM-latest.tgz (only ARM version works with Pi4B)
- https://github.com/Determinant/dump1090-fa-stratux (based on dump1090-fa)
- https://osmocom.org/projects/rtl-sdr/ (apt version required for dump1090-fa)
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

Limitations/Modifications
- WiFi configuration not available (only via ssh)
- fancontrol service disabled
- selfupdate won't work
- commandline aliases not available (yet)

not implemented/added yet:
- https://github.com/steve-m/kalibrate-rtl
- flexible pathnames (currently hardcoded)
