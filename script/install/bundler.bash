#!/usr/bin/env bash

bundle version 2>/dev/null || {
  cmd="sudo gem install bundler";echo "$ $cmd"
  $cmd && {
    sudo update-alternatives --install /usr/bin/bundle bundle `dirname \`gem which bundler\``/../bin/bundle 400
  } || exit 1
}


