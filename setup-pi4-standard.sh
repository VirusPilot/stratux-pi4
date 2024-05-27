#!/bin/bash
#set -x

# prepare libs
apt install libjpeg62-turbo-dev libconfig9 rpi-update dnsmasq git libusb-1.0-0-dev build-essential \
  autoconf libtool i2c-tools libfftw3-dev libncurses-dev python3-serial jq ifplugd iptables libttspico-utils -y
apt install cmake debhelper -y

ARCH=$(getconf LONG_BIT)

# install latest golang
cd /root
if [[ $ARCH -eq 64 ]]; then
    wget https://go.dev/dl/go1.22.3.linux-arm64.tar.gz
  else
    wget https://go.dev/dl/go1.22.3.linux-armv6l.tar.gz
fi

rm -rf /root/go
rm -rf /root/go_path
tar xzf *.gz
rm *.gz

# install rtl-sdr-blog driver
git clone https://github.com/rtlsdrblog/rtl-sdr-blog
cd rtl-sdr-blog
sudo dpkg-buildpackage -b --no-sign
cd ..

sudo dpkg -i librtlsdr0_*.deb
sudo dpkg -i librtlsdr-dev_*.deb
sudo dpkg -i rtl-sdr_*.deb
rm -f *.deb
rm -f *.buildinfo
rm -f *.changes

# install kalibrate-rtl
cd /root
rm -rf /root/kalibrate-rtl
git clone https://github.com/steve-m/kalibrate-rtl
cd kalibrate-rtl
./bootstrap && CXXFLAGS='-W -Wall -O3'
./configure
make -j8 && make install
rm -rf /root/kalibrate-rtl

# Prepare wiringpi for ogn trx via GPIO
cd /root && git clone https://github.com/WiringPi/WiringPi.git
cd WiringPi && ./build
cd /root && rm -r WiringPi

# clone stratux
cd /root
rm -r /root/stratux
git clone --recursive https://github.com/b3nn0/stratux.git /root/stratux
cd /root/stratux

# set "arm_64bit=0" in case of 32bit
if [[ $ARCH -eq 32 ]]; then
  sed -i image/config.txt -e "s/arm_64bit=1/arm_64bit=0/g"
fi

# copy various files from /root/stratux/image
cd /root/stratux/image
cp -f config.txt /boot/firmware/config.txt # modified in https://github.com/VirusPilot/stratux
cp -f bashrc.txt /root/.bashrc
cp -f rc.local /etc/rc.local
cp -f modules.txt /etc/modules
cp -f motd /etc/motd
cp -f rtl-sdr-blacklist.conf /etc/modprobe.d/
cp -f stxAliases.txt /root/.stxAliases
cp -f stratux-dnsmasq.conf /etc/dnsmasq.d/stratux-dnsmasq.conf
cp -f wpa_supplicant_ap.conf /etc/wpa_supplicant/wpa_supplicant_ap.conf
cp -f interfaces /etc/network/interfaces
cp -f sshd_config /etc/ssh/sshd_config

#rootfs overlay stuff
cp -f overlayctl init-overlay /sbin/
overlayctl install
# init-overlay replaces raspis initial partition size growing.. Make sure we call that manually (see init-overlay script)
#touch /var/grow_root_part
mkdir -p /overlay/robase # prepare so we can bind-mount root even if overlay is disabled

# So we can import network settings if needed
touch /boot/firmware/.stratux-first-boot

# Optionally mount /dev/sda1 as /var/log - for logging to USB stick
#echo -e "\n/dev/sda1             /var/log        auto    defaults,nofail,noatime,x-systemd.device-timeout=1ms  0       2" >> /etc/fstab

#disable serial console, disable rfkill state restore, enable wifi on boot
sed -i /boot/firmware/cmdline.txt -e "s/console=serial0,[0-9]\+ /systemd.restore_state=0 rfkill.default_state=1 /"

# prepare services
systemctl enable ssh
systemctl disable dnsmasq # we start it manually on respective interfaces
systemctl disable hciuart
systemctl disable triggerhappy
systemctl disable wpa_supplicant
systemctl disable apt-daily.timer
systemctl disable apt-daily-upgrade.timer
systemctl disable man-db.timer
systemctl disable systemd-timesyncd

# Run DHCP on eth0 when cable is plugged in
sed -i -e 's/INTERFACES=""/INTERFACES="eth0"/g' /etc/default/ifplugd

# Generate ssh key for all installs. Otherwise it would have to be done on each boot, which takes a couple of seconds
ssh-keygen -A -v
systemctl disable regenerate_ssh_host_keys
# This is usually done by the console-setup service that takes quite long of first boot..
/lib/console-setup/console-setup.sh

# build Stratux Europe
source /root/.bashrc
cd /root/stratux
make
make install

# disable swapfile 
systemctl disable dphys-swapfile
apt purge dphys-swapfile -y
apt autoremove -y
apt clean

# disable autologin
rm -f rm /etc/systemd/system/getty@tty1.service.d/autologin.conf

# ask for reboot
echo
read -t 1 -n 10000 discard 
read -p "Reboot now? [y/n]" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  reboot
fi
