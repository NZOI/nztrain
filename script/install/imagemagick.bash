#!/usr/bin/env bash

convert -version >/dev/null 2>&1 && { # already installed
  min_version=6
  version=`convert -version | head -1 | sed 's/[^0-9.-]*\([0-9.-]*\).*/\1/'`

  larger=`echo -e "$version\n$min_version" | sort -V | tail -1`

  if [[ $version != $larger ]] ; then
    echo "ImageMagick $min_version+ required!"
  else
    exit 0
  fi
}

while [ -z "$confirm" ] ; do
  read -p 'Install ImageMagick? (Y/y/N/n) ' confirm
  case $confirm in
    [nN] ) exit 1 ;;
    [yY] ) ;;
    "" ) confirm=true ;;
    * ) unset confirm
  esac
done

cmd="sudo apt-get install imagemagick"
echo "$ $cmd"
$cmd

