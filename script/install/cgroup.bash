#!/usr/bin/env bash

# run this script as root

source "`dirname $0`/../install.cfg"

if $ISOLATE_CGROUPS; then
  apt-get install cgroup-bin libcgroup1
fi

