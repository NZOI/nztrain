#!/usr/bin/env bash

min_version=6
convert -version 2>/dev/null | bash script/extract_version.bash | bash script/check_version.bash $min_version || { # already installed
  echo ImageMagick $min_version+ required!
  bash script/confirm.bash "Install ImageMagick" && {
    cmd="sudo apt-get install imagemagick"
    echo "$ $cmd"
    $cmd
  } || exit 1
}

cmd="sudo apt-get install libmagickwand-dev" # required by the RMagick gem
echo "$ $cmd"
$cmd || exit 1

