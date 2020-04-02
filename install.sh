#!/bin/bash
#set -x

echo
read -t 1 -n 10000 discard
read -p "apt packages already installed? [y/n]" -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
  apt update
  apt full-upgrade
  apt install libncurses5-dev -y
  apt install pkg-config -y
  apt install libjpeg8-dev -y
  apt install libconfig9 -y
  apt install hostapd -y
  apt install tcpdump -y
  apt install git -y
  apt install cmake -y
  apt install autoconf -y
  apt install libtool -y
  apt install i2c-tools -y
  apt install librtlsdr0 -y
  apt install librtlsdr-dev -y
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

cd /root
rm -r /root/stratux
git clone https://github.com/b3nn0/stratux.git
cd /root/stratux
git clone --branch stratux https://github.com/Determinant/dump1090-fa-stratux.git dump1090
git submodule update --init --recursive goflying

cd /root/stratux/ogn
rm -r rtlsdr*
wget http://download.glidernet.org/arm/rtlsdr-ogn-bin-ARM-latest.tgz
tar xvzf *.tgz
rm *.tgz

cp -f /root/stratux-pi4/stratux.conf /etc/stratux.conf
cp -f /root/stratux-pi4/stratux-ogn.conf.template /etc/stratux-ogn.conf.template
cp -f /root/stratux-pi4/Makefile /root/stratux/Makefile

cp -f /root/stratux-pi4/stratux.service /lib/systemd/system/stratux.service
chmod 644 /lib/systemd/system/stratux.service
ln -fs /lib/systemd/system/stratux.service /etc/systemd/system/multi-user.target.wants/stratux.service

cp -f /root/stratux-pi4/stratux-pre-start.sh /root/stratux-pre-start.sh
chmod 744 /root/stratux-pre-start.sh

cp -f /root/stratux-pi4/dump1090 /usr/bin/
chmod 755 /usr/bin/dump1090

cd /root/stratux
export PATH=/usr/lib/go/bin:${PATH}
export GOROOT=/usr/lib/go
export GOPATH=/usr/lib/go_path
echo export PATH=/usr/lib/go/bin:${PATH} >> ~/.bashrc
echo export GOROOT=/usr/lib/go >> ~/.bashrc
echo export GOPATH=/usr/lib/go_path >> ~/.bashrc
ldconfig
make && make install

echo
read -t 1 -n 10000 discard
read -p "i2c already enabled? [y/n]" -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
  raspi-config
fi
