#!/bin/bash
#set -x

rfkill unblock 0
ifconfig wlan0 up

timedatectl set-timezone Europe/Berlin

# prepare libs
apt install build-essential automake autoconf libncurses-dev pkg-config libjpeg62-turbo-dev libconfig9 hostapd isc-dhcp-server tcpdump git cmake libtool i2c-tools libusb-1.0-0-dev libfftw3-dev -y

# install wiringPi 2.60 (required for Pi4B)
cd /root
rm -rf /root/WiringPi
git clone https://github.com/WiringPi/WiringPi
cd WiringPi
./build
ldconfig

# install latest golang
cd /root
ARCH=$(arch)
if [ $ARCH == aarch64 ]
    then
        wget https://dl.google.com/go/go1.16.2.linux-arm64.tar.gz
    else # [ $ARCH == armv7l ]
        wget https://dl.google.com/go/go1.16.2.linux-armv6l.tar.gz
fi
rm -rf /root/go
rm -rf /root/go_path
tar xzf *.gz
rm *.gz

# install librtlsdr
cd /root
rm -rf /root/rtl-sdr
git clone https://github.com/osmocom/rtl-sdr.git
cd rtl-sdr
mkdir build
cd build
cmake ../ -DENABLE_ZEROCOPY=0
make -j8 && make install
ldconfig

# install kalibrate-rtl
cd /root
rm -rf /root/kalibrate-rtl
git clone https://github.com/steve-m/kalibrate-rtl
cd kalibrate-rtl
./bootstrap && CXXFLAGS='-W -Wall -O3'
./configure
make && make install

# install stratux-radar-display
echo
read -t 1 -n 10000 discard
read -p "Install Radar Display? [y/n]"
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  cd /root
  rm -rf /root/stratux-radar-display
  apt install libatlas-base-dev zlib1g-dev libfreetype6-dev liblcms2-dev libopenjp2-7 libtiff5 python3-pip python3-pil espeak-ng espeak-ng-data libespeak-ng-dev libbluetooth-dev -y
  pip3 install luma.oled websockets py-espeak-ng pybluez pydbus numpy
  git clone https://github.com/TomBric/stratux-radar-display.git
fi

# clone stratux
cd /root
rm -r /root/stratux
git clone --recursive -b dev https://github.com/VirusPilot/stratux.git /root/stratux
cd /root/stratux

# copy various files from /root/stratux/image
cd /root/stratux/image
cp -f config.txt /boot/config.txt
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

# prepare services
systemctl enable isc-dhcp-server
systemctl enable ssh
systemctl disable dhcpcd
systemctl disable hciuart
systemctl disable hostapd
