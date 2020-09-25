#!/bin/bash
#set -x

rfkill unblock 0
ifconfig wlan0 up

# prepare libs
apt install build-essential -y
apt install automake -y
apt install autoconf -y
apt install libncurses-dev -y
apt install pkg-config -y
apt install libjpeg8 -y
apt install libconfig9 -y
apt install hostapd -y
apt install isc-dhcp-server -y
apt install tcpdump -y
apt install git -y
apt install cmake -y
apt install libtool -y
apt install i2c-tools -y
apt install librtlsdr0 -y
apt install librtlsdr-dev -y
apt install rtl-sdr -y
apt install libfftw3-dev -y
apt install python-smbus -y
apt install python-pip -y
apt install python-dev -y
apt install python-pil -y
apt install python-daemon -y
apt install screen -y

# install wiringPi 2.52 (required for Pi4B)
wget https://project-downloads.drogon.net/wiringpi-latest.deb
dpkg -i *.deb
rm *.deb
ldconfig

# install latest golang
cd /root
rm -rf /root/go
rm -rf /root/go_path
wget https://dl.google.com/go/go1.15.2.linux-armv6l.tar.gz
tar xzf *.gz
rm *.gz
#potentially add to .bashrc.txt: export GO111MODULE=on

# replace librtlsdr.pc (https://github.com/antirez/dump1090/issues/142#issuecomment-517997954)
cp -f /root/stratux-pi4/librtlsdr.pc /usr/lib/arm-linux-gnueabihf/pkgconfig/librtlsdr.pc

# Replace librtlsdr on Raspbian (see https://github.com/wiedehopf/adsb-wiki/wiki/Replace-librtlsdr-on-Raspbian)
cd /root
rm -rf /root/rtl-sdr
git clone --depth=1 https://github.com/osmocom/rtl-sdr.git
cd rtl-sdr
mkdir build
cd build
CFLAGS="-march=native" cmake .. -DDETACH_KERNEL_DRIVER=ON
make -j2
sudo cp src/librtlsdr.so.0.6git /usr/lib/arm-linux-gnueabihf
sudo ln -nsf /usr/lib/arm-linux-gnueabihf/librtlsdr.so.0.6git /usr/lib/arm-linux-gnueabihf/librtlsdr.so.0

# install kalibrate-rtl
cd /root
rm -rf /root/kalibrate-rtl
git clone https://github.com/steve-m/kalibrate-rtl
cd kalibrate-rtl
./bootstrap && CXXFLAGS='-W -Wall -O3'
./configure
make
make install

# clone stratux
cd /root
rm -r /root/stratux
git clone --recursive https://github.com/b3nn0/stratux.git /root/stratux
cd /root/stratux

# use latest config.txt for pi4 compatibility
cp -f /root/stratux-pi4/config.txt /boot/config.txt

# replace Makefile
cp -f /root/stratux-pi4/Makefile /root/stratux/Makefile

# copy stratux service file
cp __lib__systemd__system__stratux.service /lib/systemd/system/stratux.service
chmod 644 /lib/systemd/system/stratux.service
ln -fs /lib/systemd/system/stratux.service /etc/systemd/system/multi-user.target.wants/stratux.service

# copy stratux pre-start file
cp __root__stratux-pre-start.sh /root/stratux-pre-start.sh
chmod 744 /root/stratux-pre-start.sh

# copy fancontrol with PWM disabled
cp -f /root/stratux-pi4/fancontrol.go /root/stratux/main/fancontrol.go

# copy various files from /root/stratux/image
cd /root/stratux/image
cp -f bashrc.txt /root/.bashrc
cp -f rc.local /etc/rc.local
cp -f modules.txt /etc/modules
cp -f motd /etc/motd
cp -f 10-stratux.rules /etc/udev/rules.d
cp -f 99-uavionix.rules /etc/udev/rules.d
cp -f logrotate.conf /etc/logrotate.conf
cp -f rtl-sdr-blacklist.conf /etc/modprobe.d/
cp -f stxAliases.txt /root/.stxAliases
cp -f dhcpd.conf /etc/dhcp/dhcpd.conf
cp -f dhcpd.conf.template /etc/dhcp/dhcpd.conf.template
cp -f hostapd.conf /etc/hostapd/hostapd.conf
cp -f hostapd.conf.template /etc/hostapd/hostapd.conf.template
cp -f wpa_supplicant.conf.template /etc/wpa_supplicant/wpa_supplicant.conf.template
cp -f hostapd_manager.sh /usr/sbin/hostapd_manager.sh
chmod 755 /usr/sbin/hostapd_manager.sh
rm -f /etc/rc*.d/*hostapd /etc/network/if-pre-up.d/hostapd /etc/network/if-post-down.d/hostapd /etc/init.d/hostapd /etc/default/hostapd0
cp -f interfaces /etc/network/interfaces
cp -f interfaces.template /etc/network/interfaces.template
cp stratux-wifi.sh /usr/sbin/stratux-wifi.sh
chmod 755 /usr/sbin/stratux-wifi.sh
cp -f isc-dhcp-server /etc/default/isc-dhcp-server
cp -f sshd_config /etc/ssh/sshd_config

# copy various /root/stratux/test/screen files, just in case required later
cd /root/stratux/test/screen
cp -f screen.py /usr/bin/stratux-screen.py
mkdir -p /etc/stratux-screen/
cp -f stratux-logo-64x64.bmp /etc/stratux-screen/stratux-logo-64x64.bmp
cp -f CnC_Red_Alert.ttf /etc/stratux-screen/CnC_Red_Alert.ttf

# prepare services
systemctl enable isc-dhcp-server
systemctl enable ssh
systemctl disable dhcpcd
systemctl disable hciuart
systemctl disable hostapd
