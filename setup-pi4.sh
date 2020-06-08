#!/bin/bash
#set -x

rfkill unblock 0
ifconfig wlan0 up

# prepare libs
apt install libncurses-dev -y
apt install pkg-config -y
apt install libjpeg8 -y
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
#apt install golang -y
apt install libfftw3-dev -y
apt install python-smbus -y
apt install python-pip -y
apt install python-dev -y
apt install python-pil -y
apt install python-daemon -y
apt install screen -y

wget https://project-downloads.drogon.net/wiringpi-latest.deb
dpkg -i *.deb
rm *.deb
ldconfig

# install golang
cd /root
wget https://dl.google.com/go/go1.14.4.linux-armv6l.tar.gz
tar xzf *.gz
rm *.gz

# intall kalibrate-rtl
cd /root
rm -rf kalibrate-rtl
git clone https://github.com/steve-m/kalibrate-rtl
cd kalibrate-rtl
./bootstrap
./configure
make -j8
make install

# clone stratux
cd /root
rm -r /root/stratux
git clone https://github.com/b3nn0/stratux.git /root/stratux
cd /root/stratux
# replace dump1090 with dump1090-fa
rm -r /root/stratux/dump1090
git clone --branch stratux https://github.com/Determinant/dump1090-fa-stratux.git dump1090
git submodule update --init --recursive goflying
# copy dump1090 link file
cp -f /root/stratux-pi4/dump1090 /usr/bin/
chmod 755 /usr/bin/dump1090
# enable i2c
cp -f /root/stratux-pi4/config.txt /boot/config.txt
cp -f /root/stratux-pi4/modules /etc/modules
# replace Makefile
cp -f /root/stratux-pi4/Makefile /root/stratux/Makefile
# copy stratux service file with stratux-pre-start removed
cp -f /root/stratux-pi4/stratux.service /lib/systemd/system/stratux.service
chmod 644 /lib/systemd/system/stratux.service
ln -fs /lib/systemd/system/stratux.service /etc/systemd/system/multi-user.target.wants/stratux.service
# copy rc.local with screen.py deactivated
cp -f /root/stratux-pi4/rc.local /etc/rc.local
# copy .bashrc with modified GO env
#cp -f /root/stratux-pi4/bashrc.txt /root/.bashrc
# copy interface file with static eth0 IP
#cp -f /root/stratux-pi4/interfaces /etc/network/interfaces
#cp -f /root/stratux-pi4/interfaces.template /etc/network/interfaces.template
# copy various files from /root/stratux/image
cd /root/stratux/image
cp -f bashrc.txt /root/.bashrc
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
# prepare isc-dhcp-server network
systemctl enable isc-dhcp-server
systemctl enable ssh
#systemctl disable ntp
systemctl disable dhcpcd
systemctl disable hciuart
systemctl disable hostapd
