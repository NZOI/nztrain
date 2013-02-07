#!/usr/bin/env bash

# installation specific to nztrain application - files and directory structure

# check if database.yml exists, if not, copy from database.yml.default
if [ ! -f config/database.yml ];
then
  cmd="cp config/database.yml.default config/database.yml"
  echo "$ $cmd"
  $cmd
fi

# make directories for storage
cmd="mkdir db/data/uploads/user/avatar/ -p"
echo "$ $cmd"
$cmd


