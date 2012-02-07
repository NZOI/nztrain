#!/bin/bash

# note, we are bashing the echoes so that "sh update.sh" will still print coloured output

# TODO: create db if it doesn't exist (and prompt for db details to create, or option to change details)


# install imagemagick
cmd="sudo apt-get install libmagickwand-dev libjpeg62-dev libpng12-dev libglib2.0-dev libfontconfig1 zlib1g libwmf-dev libfreetype6 libtiff4-dev libxml2 imagemagick"
bash -c "echo -e '\E[34m\033[1m$cmd\033[0m'"
$cmd


# update as normal
bash update.sh --skip-pull







