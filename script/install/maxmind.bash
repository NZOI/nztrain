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


add-apt-repository -y ppa:maxmind/ppa
apt-get update

# https://github.com/maxmind/libmaxminddb
apt-get install libmaxminddb0 libmaxminddb-dev mmdb-bin

# https://github.com/maxmind/geoipupdate
apt-get install geoipupdate





