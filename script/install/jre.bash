#!/usr/bin/env bash

cmd="sudo apt-get install default-jre-headless" # java required by yui-compressor gem
echo "$ $cmd"
$cmd
[[ $? -le 1 ]] || exit 1 # apt-get exit 0 = success, 1 = decline, otherwise unknown error

