#!/usr/bin/env bash

# installation specific to nztrain application - files and directory structure

# check if database.yml exists, if not, copy from database.yml.default
if [ ! -f config/database.yml ] ; then
  cmd="bash script/template.bash < config/database.yml.template | cat > config/database.yml"
  echo "$ $cmd"
  bash script/template.bash < config/database.yml.template | cat > config/database.yml
fi

# make directories for storage
cmd="mkdir db/data/uploads/user/avatar/ -p"; echo "$ $cmd"; $cmd
cmd="mkdir db/backup/log -p"; echo "$ $cmd"; $cmd
cmd="mkdir db/backups/ -p"; echo "$ $cmd"; $cmd


