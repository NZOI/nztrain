#!/bin/bash

for ARG in "$@"
do
    case $ARG in
    "--skip-update")
        update=false
        ;;
    *)
        ;;
    esac
done


# note, we are bashing the echoes so that "sh update.sh" will still print coloured output

cd `dirname $0`

# TODO: create db if it doesn't exist (and prompt for db details to create, or option to change details)


# install imagemagick
cmd="sudo apt-get install imagemagick"
bash -c "echo -e '\E[34m\033[1m$cmd\033[0m'"
$cmd

# check if database.yml exists, if not, copy from database.yml.default
if [ ! -f config/database.yml ];
then
  cmd="cp config/database.yml.default config/database.yml"
  bash -c "echo -e '\E[34m\033[1m$cmd\033[0m'"
  $cmd
fi

# make directories for storage
cmd="mkdir db/data/uploads/user/avatar/ -p"
bash -c "echo -e '\E[34m\033[1m$cmd\033[0m'"
$cmd

# update as normal
if ${update:=true} ; then
  bash update.sh --skip-pull
fi






