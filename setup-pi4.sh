#!/bin/bash
#set -x

rfkill unblock 0
ifconfig wlan0 up

timedatectl set-timezone Europe/Berlin

# prepare libs
apt install parted zip unzip zerofree build-essential automake autoconf libncurses-dev pkg-config libjpeg62-turbo-dev libconfig9 hostapd isc-dhcp-server tcpdump git cmake libtool i2c-tools libusb-1.0-0-dev libfftw3-dev python-serial -y

# disable swapfile
systemctl disable dphys-swapfile
apt purge dphys-swapfile -y

# cleanup
apt autoremove -y
apt clean

# disable use tmpfs for logs, tmp, var/tmp as the default setup
if ! grep -q "tmpfs" /etc/fstab; then
  echo "" >> /etc/fstab # newline
  echo "tmpfs    /var/log    tmpfs    defaults,noatime,nosuid,mode=0755,size=100m    0 0" >> /etc/fstab
  echo "tmpfs    /tmp        tmpfs    defaults,noatime,nosuid,size=100m    0 0" >> /etc/fstab
  echo "tmpfs    /var/tmp    tmpfs    defaults,noatime,nosuid,size=30m    0 0" >> /etc/fstab
fi

# install wiringPi 2.60 (required for Pi4B)
cd /root
rm -rf /root/WiringPi
git clone https://github.com/WiringPi/WiringPi
cd WiringPi
./build
rm -rf /root/WiringPi
ldconfig

# install latest golang
cd /root
wget https://golang.org/dl/go1.16.6.linux-arm64.tar.gz
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
rm -rf /root/rtl-sdr
ldconfig

# install kalibrate-rtl
cd /root
rm -rf /root/kalibrate-rtl
git clone https://github.com/steve-m/kalibrate-rtl
cd kalibrate-rtl
./bootstrap && CXXFLAGS='-W -Wall -O3'
./configure
make -j8 && make install
rm -rf /root/kalibrate-rtl

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
  pip3 install --upgrade PILLOW
  git clone https://github.com/TomBric/stratux-radar-display.git
fi

# clone stratux
cd /root
rm -r /root/stratux
git clone --recursive https://github.com/VirusPilot/stratux.git /root/stratux
cd /root/stratux

# copy various files from /root/stratux/image
cd /root/stratux/image
cp -f config.txt /boot/config.txt # modified in https://github.com/VirusPilot/stratux
cp -f bashrc.txt /root/.bashrc
cp -f rc.local /etc/rc.local # modified in https://github.com/VirusPilot/stratux
cp -f modules.txt /etc/modules
cp -f motd /etc/motd
cp -f logrotate.conf /etc/logrotate.conf
cp -f rtl-sdr-blacklist.conf /etc/modprobe.d/
cp -f stxAliases.txt /root/.stxAliases
cp -f dhcpd.conf /etc/dhcp/dhcpd.conf
cp -f hostapd.conf /etc/hostapd/hostapd.conf
cp -f interfaces /etc/network/interfaces
cp -f isc-dhcp-server /etc/default/isc-dhcp-server
cp -f sshd_config /etc/ssh/sshd_config

#Set the keyboard layout to DE and pc101
sed -i /etc/default/keyboard -e "/^XKBLAYOUT/s/\".*\"/\"de\"/"
sed -i /etc/default/keyboard -e "/^XKBMODEL/s/\".*\"/\"pc101\"/"

# prepare services
systemctl enable isc-dhcp-server
systemctl enable ssh
systemctl disable dhcpcd
systemctl disable hciuart
systemctl disable hostapd

sed -i 's/INTERFACESv4=""/INTERFACESv4="wlan0"/g' /etc/default/isc-dhcp-server
