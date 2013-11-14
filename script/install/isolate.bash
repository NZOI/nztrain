#!/usr/bin/env bash

# run this script as root

cd /usr/local/src/
if [ -d "moe" ]; then
  cd moe
  done=true
  git pull | grep -q -v 'Already up-to-date.' && done=false
  if $done; then
    exit
  fi
else
  git clone git://git.ucw.cz/moe.git
  cd moe
fi

./configure
make

chmod +s run/bin/isolate

ln -sf /usr/local/src/moe/run/bin/isolate /usr/local/bin

