#!/usr/bin/env bash

#min_version=6
#convert -version 2>/dev/null | bash script/extract_version.bash | bash script/check_version.bash $min_version || { # already installed
#  echo ImageMagick $min_version+ required!
#  bash script/confirm.bash "Install ImageMagick" && {
#    cmd="sudo apt-get install imagemagick"
#    echo "$ $cmd"
#    $cmd
#  } || exit 1
#}

cmd="sudo apt-get install default-jre-headless" # java required by yui-compressor gem
echo "$ $cmd"
$cmd
[[ $? -le 1 ]] || exit 1 # apt-get exit 0 = success, 1 = decline, otherwise unknown error

