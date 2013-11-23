#!/usr/bin/env bash

# run this script as root
source `dirname $0`/../install.cfg

srclocation=/usr/local/src
branch=nztrain
[[ "$ISOLATE_BRANCH" != "" ]] && branch="$ISOLATE_BRANCH"

cd $srclocation
if [ -d "moe" ]; then
  cd moe
  done=true
  git pull --force | grep -q -v 'Already up-to-date.' && done=false
  if $done; then
    exit
  fi
else
  git clone -b $branch https://github.com/NZOI/moe-cms moe && cd moe || exit 1
fi

./configure && make || {
  echo "Failure when configuring or making isolate - aborting"
  cd ..
  rm -r moe
  exit 1
}

chgrp $APP_USER run/bin/isolate && chmod 4750 run/bin/isolate || {
  echo "Failure to setup isolate permissions - aborting"
  cd ..
  rm -r $srclocation/moe
  exit 1
}

ln -sf $srclocation/moe/run/bin/isolate /usr/local/bin

