# Build a Stratux Europe on a Pi3B, Pi4B or Pi Zero 2 W based on a fresh 64bit RasPiOS Lite Image

# stratux-pi4-standard
- based on https://github.com/b3nn0/stratux
- latest 64bit RasPiOS Lite Image: http://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2022-01-28/2022-01-28-raspios-bullseye-arm64-lite.zip

# stratux-pi4-viruspilot
- based on my fork https://github.com/VirusPilot/stratux which has the following modifications compared to the "standard" version:
- image/config.txt: slight modifications
- main/gps.go: load default configuration for u-blox GPS before sending the Stratux related configuration, then save configuration
- main/gps.go: initial support for u-blox M10S
- main/gps.go: use Beidou instead of Glonass in case of u-blox 8 so that the three following GNSS are used: GPS, Galileio, Beidou
- main/gps.go: enable GPS LED to indicate a valid GPS fix

# stratux-pi4-viruspilot-gp (Garmin Pilot version)
- same as the obove but some preliminary support for Garmin Pilot as of version 10.6 is implemented
- the following Stratux IP Address is required: 10.29.39.1 (instead of the default address 192.168.10.1)

## please use these scripts with caution and only on a fresh Raspbian Buster Image, because:
- the entire filesystem (except /boot) will be changed to read-only to prevent microSD card corruption
- swapfile will be disabled

## prepare script for Pi3B or Pi4B:
- flash latest 64bit RasPiOS Lite Image, using etcher
- copy empty ssh file to /boot directory
- connectt Pi to LAN via Ethernet cable
- boot

## prepare script for Pi Zero 2 W:
- flash latest 64bit RasPiOS Lite Image, using etcher
- create wpa_supplcant.conf, using e.g. https://www.pistar.uk/wifi_builder.php to enable connecting to your local WiFi
- copy wpa_supplcant.conf to /boot directory
- copy empty ssh file to /boot directory
- boot and wait until your Pi is connected to your WiFi
- please note that the brightness values of the Pi Zero 2 W LED are reversed so it will turn off as soon as Stratux has successfully booted

## start build process
login as `pi` user
```
sudo su
```
standard version:
```
cd ~/
apt update
apt full-upgrade -y
apt install git -y
git clone https://github.com/VirusPilot/stratux-pi4.git
./stratux-pi4/setup-pi4-standard.sh
```
viruspilot version:
```
cd ~/
apt update
apt full-upgrade -y
apt install git -y
git clone https://github.com/VirusPilot/stratux-pi4.git
./stratux-pi4/setup-pi4-viruspilot.sh
```
viruspilot version (for Garmin Pilot):
```
cd ~/
apt update
apt full-upgrade -y
apt install git -y
git clone https://github.com/VirusPilot/stratux-pi4.git
./stratux-pi4/setup-pi4-viruspilot-gp.sh
```
- if you are all set then let the sript reboot but if you haven't yet programed your SDRs, now would be a good time before Stratux will be claiming the SDRs after a reboot; please follow the instructions under "Remarks - SDR programming" below for each SDR individually
- after reboot please reconnect LAN and/or WiFi and Stratux should work right away
- You may now install https://github.com/TomBric/stratux-radar-display, please follow the steps described here: https://github.com/TomBric/stratux-radar-display#installation-on-a-standard-stratux-device-for-stratux-versions-eu027-or-newer
- You may now install additional maps according to https://github.com/b3nn0/stratux/wiki/Downloading-better-map-data

## SkyDemon related Remarks
- WiFi Settings/Stratux IP Address 192.168.10.1 (default): only GDL90 can be selected and used in SkyDemon
- WiFi Settings/Stratux IP Address 192.168.1.1: both GDL90 and FLARM-NMEA can be selected and used in SkyDemon
- GDL90 is labeled as "GDL90 Compatible Device" under Third-Party Devices
- FLARM-NMEA is labeled as "FLARM with Air Connect" under Third-Party Devices, the "Air Connect Key" can be ignored for Stratux Europe
- info for experts: FLARM-NMEA = TCP:2000, GDL90 = UDP:4000 (for FLARM-NMEA, the EFB initiates the connection, for UDP, Stratux will send unicast to all connected DHCP clients)

## Limitations/Modifications/Issues
- these scripts also work on 32bit RasPiOS Lite Image
- this setup is intended to create a Stratux system, don't use the Pi for any other important stuff as all of your data may be lost during Stratux operation
- please note that the keyboard layout is set to DE and pc101 (if necessary please edit the /etc/default/keyboard file accordingly)

## Remarks - SDR programming simple mode
- only plug in one SDR and then execute
```
sdr-tool.sh
```

## Remarks - SDR programming expert mode (1)
During boot, Stratux tries to identify which SDR to use for which traffic type (ADS-B, OGN) - this is done by reading the "Serial number" entry in each SDRs. You can check or modify these entries as described below, it is recommended for programming to only plug in one SDR at a time, connect the appropriate antenna and label this combination accordingly, e.g. "868" for OGN.
```
stxstop (stop Stratux from claiming the SDRs)
rtl_eeprom
```
will report something like the following:
```
Current configuration:
__________________________________________
Vendor ID:              0x0bda
Product ID:             0x2838
Manufacturer:           Realtek
Product:                RTL2838UHIDIR
Serial number:          stx:868:0
Serial number enabled:  yes
IR endpoint enabled:    yes
Remote wakeup enabled:  no
__________________________________________
```
This SDR is obviosly programmed for Stratux (stx), OGN (868MHz), and a ppm correction of "0", the ppm can be modified later, see below. If your SDR comes pre-programed (it would be labled with e.g. with "1090") there is no need to program it.

You can program the `Serial number` entry with the following command:
```
rtl_eeprom -s stx:1090:0
```
to prepare it e.g. for ADS-B (1090MHz) use. A reboot is necessary to activate the new serial number.

If for some reasons an error occurs while programming, please consider preparing the SDR with the default values:
```
rtl_eeprom -g realtek
```
At this point you can already test your SDR and receive ADS-B traffic with the following command:
```
rtl_adsb -V
```
Or listen to you favorite FM radio station (my station below is at 106.9MHz) by pluging in a headset and run the following command:
```
rtl_fm -M fm -f 106.9M -s 32000 -g 60 -l 10 - | aplay -t raw -r 32000 -c 1 -f S16_LE
```
## Remarks - SDR programming expert mode (2)
During boot, Stratux furthermore reads the ppm correction from the SDR `Serial number`, e.g. if the `Serial number` is `stx:1090:28` then the ppm used by Stratux is +28. If the appropriate ppm for the SDR is unknown, here are the steps to find out (again it is useful to have only one SDR plugged in to avoid confusion):

`stxstop` (in case Stratux is already running)

`kal -s GSM900` and note donw the channel number with the highest power (e.g. 4)

`kal -b GSM900 -c 4` and note down the average absolute error (e.g. 16.325 ppm)

Once you have found the appropriate ppm (e.g. +16 as in the example above), the SDR `Serial number` needs to be programmed once again:
```
rtl_eeprom -s stx:868:16
reboot
```
For more information on how to use `kal` please visit https://github.com/steve-m/kalibrate-rtl/blob/master/README.md
