#!/usr/bin/env bash

cd `dirname $0`/../..

source script/install.cfg

update=false
# process script options
for ARG in "$@"
do
    case $ARG in
    "--update")
        update=true
        ;;
    *)
        ;;
    esac
done

cmd="sudo add-apt-repository -y ppa:maxmind/ppa"
echo "$ $cmd"
$cmd

cmd="sudo apt-get update"
echo "$ $cmd"
$cmd

# https://github.com/maxmind/libmaxminddb
cmd="sudo apt-get install libmaxminddb0 libmaxminddb-dev mmdb-bin"
echo "$ $cmd"
$cmd

# https://github.com/maxmind/geoipupdate
cmd="sudo apt-get install geoipupdate"
echo "$ $cmd"
$cmd

echo "$ sudo printf \"UserId 999999\nLicenseKey 000000000000\nProductIds GeoLite2-City\n\" > /etc/GeoIP.conf"
sudo bash -c "printf \"UserId 999999\nLicenseKey 000000000000\nProductIds GeoLite2-City\n\" > /etc/GeoIP.conf"

sudo mkdir /usr/share/GeoIP -p

cmd="sudo geoipupdate"
echo "$ $cmd"
$cmd

