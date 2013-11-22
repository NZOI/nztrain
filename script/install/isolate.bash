#!/usr/bin/env bash

# run this script as root
source `dirname $0`/../install.cfg

cd /usr/local/src/
if [ -d "moe" ]; then
  cd moe
  done=true
  git pull --force | grep -q -v 'Already up-to-date.' && done=false
  if $done; then
    exit
  fi
else
  git clone -b nztrain https://github.com/NZOI/moe-cms moe
  cd moe
fi

./configure
make

chgrp $APP_USER run/bin/isolate
chmod 4750 run/bin/isolate

ln -sf /usr/local/src/moe/run/bin/isolate /usr/local/bin

