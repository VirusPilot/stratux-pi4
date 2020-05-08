#!/bin/bash
#set -x

echo
read -t 1 -n 10000 discard
read -p "install required apt packages? [y/n]" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  apt update
  apt full-upgrade -y
  apt install libncurses-dev -y
  apt install pkg-config -y
  apt install libjpeg8-dev -y
  apt install libconfig9 -y
  apt install hostapd -y
  apt install isc-dhcp-server -y
  apt install tcpdump -y
  apt install git -y
  apt install cmake -y
  apt install autoconf -y
  apt install libtool -y
  apt install i2c-tools -y
  apt install librtlsdr0 -y
  apt install librtlsdr-dev -y
  apt install rtl-sdr -y
  apt install golang -y
  wget https://project-downloads.drogon.net/wiringpi-latest.deb
  wget http://ftp.debian.org/debian/pool/main/f/fftw3/libfftw3-bin_3.3.5-3_armhf.deb
  wget http://ftp.debian.org/debian/pool/main/f/fftw3/libfftw3-dev_3.3.5-3_armhf.deb
  wget http://ftp.debian.org/debian/pool/main/f/fftw3/libfftw3-double3_3.3.5-3_armhf.deb
  wget http://ftp.debian.org/debian/pool/main/f/fftw3/libfftw3-single3_3.3.5-3_armhf.deb
  dpkg -i *.deb
  rm *.deb
  apt-mark hold libfftw3-bin
  apt-mark hold libfftw3-dev
  apt-mark hold libfftw3-double3
  apt-mark hold libfftw3-single3
fi

systemctl enable isc-dhcp-server
systemctl enable ssh
systemctl disable ntp
systemctl disable dhcpcd
systemctl disable hciuart
systemctl disable hostapd

cp -f /root/stratux-pi4/Makefile /root/stratux/Makefile
cp -f /root/stratux-pi4/config.txt /boot/config.txt
cp -f /root/stratux-pi4/dump1090 /usr/bin/
chmod 755 /usr/bin/dump1090

rm -r /root/stratux
git clone https://github.com/b3nn0/stratux.git

cd /root/stratux
git clone --branch stratux https://github.com/Determinant/dump1090-fa-stratux.git dump1090
git submodule update --init --recursive goflying

export PATH=/usr/lib/go/bin:${PATH}
export GOROOT=/usr/lib/go
export GOPATH=/usr/lib/go_path

cd /root/stratux
go get github.com/prometheus/procfs
cd $GOPATH/src/github.com/prometheus/procfs/
git checkout tags/v0.0.11

cd /root/stratux/ogn
mv -f rtlsdr-ogn/stratux.conf.template .
mv -f rtlsdr-ogn/rtlsdr-ogn.conf .
rm -r rtlsdr-ogn
rm -r rtlsdr-ogn-*
wget http://download.glidernet.org/arm/rtlsdr-ogn-bin-ARM-latest.tgz
tar xvzf *.tgz
rm *.tgz
mv -f stratux.conf.template rtlsdr-ogn/stratux.conf.template
mv -f rtlsdr-ogn.conf rtlsdr-ogn/rtlsdr-ogn.conf

cd /root/stratux/image
cp -f bashrc.txt /root/.bashrc
source /root/.bashrc
cp -f motd /etc/motd
cp -f dhcpd.conf /etc/dhcp/dhcpd.conf
cp -f dhcpd.conf.template /etc/dhcp/dhcpd.conf.template
cp -f hostapd.conf /etc/hostapd/hostapd.conf
cp -f hostapd.conf.template /etc/hostapd/hostapd.conf.template
cp -f wpa_supplicant.conf.template /etc/wpa_supplicant/wpa_supplicant.conf.template
cp -f hostapd_manager.sh /usr/sbin/hostapd_manager.sh
chmod 755 /usr/sbin/hostapd_manager.sh
rm -f /etc/rc*.d/*hostapd /etc/network/if-pre-up.d/hostapd /etc/network/if-post-down.d/hostapd /etc/init.d/hostapd /etc/default/hostapd
cp -f interfaces /etc/network/interfaces
cp -f interfaces.template /etc/network/interfaces.template
cp stratux-wifi.sh /usr/sbin/stratux-wifi.sh
chmod 755 /usr/sbin/stratux-wifi.sh
cp -f sdr-tool.sh /usr/sbin/sdr-tool.sh
chmod 755 /usr/sbin/sdr-tool.sh
cp -f 99-uavionix.rules /etc/udev/rules.d
cp -f logrotate.conf /etc/logrotate.conf
cp -f isc-dhcp-server /etc/default/isc-dhcp-server
cp -f sshd_config /etc/ssh/sshd_config
cp -f 10-stratux.rules /etc/udev/rules.d
cp -f stxAliases.txt /root/.stxAliases
cp -f rtl-sdr-blacklist.conf /etc/modprobe.d/
cp -f modules.txt /etc/modules
cp -f ../__lib__systemd__system__stratux.service /lib/systemd/system/stratux.service
cp -f ../__root__stratux-pre-start.sh /root/stratux-pre-start.sh
cp -f rc.local /etc/rc.local

ldconfig

cd /root/stratux
make && make install

echo
read -t 1 -n 10000 discard
read -p "reboot? [y/n]" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  reboot
fi
