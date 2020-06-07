
LFLAGS=-X main.stratuxVersion=`git describe --tags --abbrev=0` -X main.stratuxBuild=`git log -n 1 --pretty=%H`
BUILDINFO+=-ldflags "$(LFLAGS)"
BUILDINFO_STATIC=-ldflags "-extldflags -static $(LFLAGS)"

all:
	make xdump978 xdump1090 xgen_gdl90 fancontrol www

xgen_gdl90:
	go get -t -d -v ./main ./godump978 ./uatparse ./sensors
	export CGO_CFLAGS_ALLOW="-L/root/stratux" && go build $(BUILDINFO) -p 4 main/gen_gdl90.go main/traffic.go main/gps.go main/network.go main/managementinterface.go main/sdr.go main/ping.go main/uibroadcast.go main/monotonic.go main/datalog.go main/equations.go main/sensors.go main/cputemp.go main/lowpower_uat.go main/ogn.go main/flarm-nmea.go main/networksettings.go main/xplane.go

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

ogn/ddb.json:
	cd ogn && ./fetch_ddb.sh

install: ogn/ddb.json
	cp -f libdump978.so /usr/lib/libdump978.so
	cp -f gen_gdl90 /usr/bin/gen_gdl90
	chmod 755 /usr/bin/gen_gdl90
	cp -f ogn/ogn-rx-eu_arm /usr/bin/ogn-rx-eu
	cp -f ogn/ddb.json /etc/

clean:
	rm -f gen_gdl90 libdump978.so fancontrol ahrs_approx
	cd dump1090 && make clean
	cd dump978 && make clean
