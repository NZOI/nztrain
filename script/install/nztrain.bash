#!/usr/bin/env bash

if [ -z $CONFIG_LOADED ]; then
  source script/install.cfg
fi

# installation specific to nztrain application - files and directory structure

# check if database.yml exists, if not, generate from database.yml.template
if [ ! -f config/database.yml ] || [ config/database.yml.template -nt config/database.yml ] ; then
  cmd="bash script/template.bash < config/database.yml.template | cat > config/database.yml"
  echo "$ $cmd"
  bash script/template.bash < config/database.yml.template | cat > config/database.yml
fi

# check if backup.yml exists, if not, generate from backup.yml.template
if [ ! -f config/backup.yml ] ; then
  cmd="bash script/template.bash < config/backup.yml.template | cat > config/backup.yml"
  echo "$ $cmd"
  bash script/template.bash < config/backup.yml.template | cat > config/backup.yml
fi

# get unicorn.yml up
if [ ! -f config/unicorn.yml ] ; then
  cmd="bash script/template.bash < config/unicorn.yml.template | cat > config/unicorn.yml"
  echo "$ $cmd"
  bash script/template.bash < config/unicorn.yml.template | cat > config/unicorn.yml
fi

# get isolate.yml up
if [ ! -f config/isolate.yml ] ; then
  cmd="bash script/template.bash < config/isolate.yml.template | cat > config/isolate.yml"
  echo "$ $cmd"
  bash script/template.bash < config/isolate.yml.template | cat > config/isolate.yml
fi

# get redis.yml up
if [ ! -f config/redis.yml ] ; then
  cmd="bash script/template.bash < config/redis.yml.template | cat > config/redis.yml"
  echo "$ $cmd"
  bash script/template.bash < config/redis.yml.template | cat > config/redis.yml
fi

# make directories for storage
cmd="mkdir db/data/downloads/importers/coci/ -p"; echo "$ $cmd"; $cmd
cmd="mkdir db/data/uploads/user/avatar/ -p"; echo "$ $cmd"; $cmd
cmd="mkdir db/backup/log -p"; echo "$ $cmd"; $cmd
cmd="mkdir db/backups/ -p"; echo "$ $cmd"; $cmd


