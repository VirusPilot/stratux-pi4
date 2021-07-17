# stratux-pi4 (64bit)
Build a Stratux Europe on a Pi4B (Pi3B tested as well) based on a fresh 64bit Raspbian Buster Lite Image.
A Pi4B with at least 2GB RAM is recommended, particularly in light of the disabled swapfile and the use of 230MB tmpfs

This started as a script just for myself to build a Stratux Europe for a Pi4B, based on:
- Raspberry Pi4B (also tested on Pi3B)
- Latest Raspbian Buster Lite 64bit from here: http://downloads.raspberrypi.org/raspios_lite_arm64/images/
- https://github.com/VirusPilot/stratux

It furthermore now (optionally) includes https://github.com/TomBric/stratux-radar-display
- please note that the setup script execution takes significantly longer (only once)
- in /etc/rc.local you need to enable your particular display type after the setup script has finished

A list of differences to the original Stratux Europe Edition
- slightly modified system files (config.txt)
- radar display autostart prepared but disabled in /etc/rc.local
- ublox AssistNow Autonomous enabled and configuration saved

## Please use this script with caution and only on a fresh Raspbian Buster Image, because:
- fstab will be changed to use tmpfs for logs, tmp, var/tmp
- swapfile will be disabled

## Steps required:
- Pi4B connected to LAN via Ethernet cable
- boot from a fresh Raspbian Buster Lite Image with ssh enabled
- login as `pi` user
```
sudo su
cd ~/
apt update
apt full-upgrade
```
```
reboot
```
If you haven't yet programed your SDRs, please first follow the instructions under "Remarks - SDR programming" below for each SDR individually or otherwise just continue here:
```
apt install git -y
git clone https://github.com/VirusPilot/stratux-pi4.git
./stratux-pi4/setup-pi4.sh
source /root/.bashrc
cd stratux
make && make install
```
```
reboot
```

After reboot please reconnect LAN and/or WiFi and Stratux should work right away.

## SkyDemon related Remarks
- WiFi Settings/Stratux IP Address 192.168.10.1 (default): only GDL90 can be selected and used in SkyDemon
- WiFi Settings/Stratux IP Address 192.168.1.1: both GDL90 and FLARM-NMEA can be selected and used in SkyDemon
- GDL90 is labeled as "GDL90 Compatible Device" under Third-Party Devices
- FLARM-NMEA is labeled as "FLARM with Air Connect" under Third-Party Devices, the "Air Connect Key" can be ignored for Stratux Europe
- info for experts: FLARM-NMEA = TCP:2000, GDL90 = UDP:4000 (for FLARM-NMEA, the EFB initiates the connection, for UDP, Stratux will send unicast to all connected DHCP clients)

## Limitations/Modifications/Issues
- 64bit version only work on Pi3B or Pi4B
- this setup is intended to create a Stratux system, don't use the Pi for any other important stuff as all of your data may be lost during Stratux operation
- please note that the keyboard layout is set to DE and pc101 (if necessary please edit the /etc/default/keyboard file accordingly)

## Remarks - SDR programming (1)
During boot, Stratux tries to identify which SDR to use for which traffic type (ADS-B, OGN) - this is done by reading the "Serial number" entry in each SDRs. You can check or modify these entries as described below, it is recommended for programming to only plug in one SDR at a time, connect the appropriate antenna and label this combination accordingly, e.g. "868" for OGN.
```
apt install rtl-sdr -y
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

At this point you can already test your SDR and receive ADS-B traffic with the following command:
```
rtl_adsb -V"
```
Or listen to you favorite FM radio station (my station below is at 106.9MHz) by pluging in a headset and run the following command:
```
rtl_fm -M fm -f 106.9M -s 32000 -g 60 -l 10 - | aplay -t raw -r 32000 -c 1 -f S16_LE".
```
## Remarks - SDR programming (2)
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
