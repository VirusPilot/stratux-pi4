
LDFLAGS_VERSION=-X main.stratuxVersion=`git describe --tags --abbrev=0` -X main.stratuxBuild=`git log -n 1 --pretty=%H`
BUILDINFO=-ldflags "$(LDFLAGS_VERSION)"
BUILDINFO_STATIC=-ldflags "-extldflags -static $(LDFLAGS_VERSION)"

all:
	make xdump978 xdump1090 xgen_gdl90 fancontrol www

xgen_gdl90:
	go get -t -d -v ./main ./godump978 ./uatparse ./sensors
	export CGO_CFLAGS_ALLOW="-L/root/stratux" && go build $(BUILDINFO) -p 4 main/gen_gdl90.go main/traffic.go main/gps.go main/network.go main/managementinterface.go main/sdr.go main/ping.go main/uibroadcast.go main/monotonic.go main/datalog.go main/equations.go main/sensors.go main/cputemp.go main/lowpower_uat.go main/flarm.go main/flarm-nmea.go main/networksettings.go main/xplane.go

fancontrol:
	go get -t -d -v ./main
	go build $(BUILDINFO) -p 4 main/fancontrol.go main/equations.go main/cputemp.go

xdump1090:
	cd dump1090 && make BLADERF=no

xdump978:
	cd dump978 && make lib
	sudo cp -f ./libdump978.so /usr/lib/libdump978.so

www:
	cd web && make

install:
	cp -f libdump978.so /usr/lib/libdump978.so

	cp -f gen_gdl90 /usr/bin/gen_gdl90
	chmod 755 /usr/bin/gen_gdl90

	cp -f image/10-stratux.rules /etc/udev/rules.d/10-stratux.rules
	cp -f image/99-uavionix.rules /etc/udev/rules.d/99-uavionix.rules
	cp -f image/stxAliases.txt /root/.stxAliases
	cp -f image/rtl-sdr-blacklist.conf /etc/modprobe.d/
	cp -f image/rc.local /etc/rc.local
	cp -f image/logrotate.conf /etc/logrotate.conf

	cp -f image/hostapd_manager.sh /usr/sbin/
	cp -f image/stratux-wifi.sh /usr/sbin/
	cp -f image/hostapd.conf.template /etc/hostapd/
	cp -f image/interfaces.template /etc/network/
	cp -f image/wpa_supplicant.conf.template /etc/wpa_supplicant/

	rm -f /var/run/ogn-rf.fifo
	mkfifo /var/run/ogn-rf.fifo

	cp -f ogn/rtlsdr-ogn/ogn-rf /usr/bin/
	chmod a+s /usr/bin/ogn-rf
	cp -f ogn/rtlsdr-ogn/ogn-decode /usr/bin/
	cp -f ogn/ddb.json /etc/

	touch /etc/stratux.conf
	chmod a+rw /etc/stratux.conf

clean:
	rm -f gen_gdl90 libdump978.so fancontrol ahrs_approx
	cd dump1090 && make clean
	cd dump978 && make clean
