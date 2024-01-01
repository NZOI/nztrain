#!/usr/bin/env bash

# run this script as root
source `dirname $0`/../install.cfg

srclocation=/usr/local/src

cd $srclocation
if [ -d "isolate" ]; then
  cd isolate
  done=true
  git pull --force | grep -q -v 'Already up-to-date.' && done=false
  if $done; then
    exit
  fi
else
  git clone -b $ISOLATE_BRANCH https://github.com/ioi/isolate isolate && cd isolate || exit 1
fi

apt-get install libcap-dev

make install || {
  echo "Failure when configuring or making isolate - aborting"
  cd ..
  rm -r isolate
  exit 1
}

chgrp "$APP_GROUP" /usr/local/bin/isolate || exit 1
chmod 4750 /usr/local/bin/isolate || exit 1 # change permissions from default (4755) to prevent other users from executing, because it is setuid
