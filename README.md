# stratux-pi4
Build a Stratux Europe on a Pi4B (Pi3B tested as well) based on a fresh Buster image

This started as a script just for myself to build a Stratux Europe, based on:
- https://github.com/b3nn0/stratux
- https://project-downloads.drogon.net/wiringpi-latest.deb
- http://download.glidernet.org/arm/rtlsdr-ogn-bin-ARM-latest.tgz
- Raspbian Buster Lite
- Raspberry Pi 4 B (also tested on Pi 3 B)

Steps required:
- fresh Raspbian Buster Lite Image running with ssh
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
