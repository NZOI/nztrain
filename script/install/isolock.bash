#!/usr/bin/env bash

# run this script as root

cd /usr/local/src/
if [ -d "isolock" ]; then
  cd isolock
  done=true
  git pull | grep -q -v 'Already up-to-date.' && done=false
  if $done; then
    exit
  fi
else
  git clone https://github.com/ronalchn/isolock.git
  cd isolock
fi

make

chmod +s bin/isolock

ln -s /usr/local/src/isolock/bin/isolock /usr/local/bin

