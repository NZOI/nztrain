#!/usr/bin/env bash

cd `dirname $0`/../..

source script/install.cfg

# header files (required by pg gem)
cmd="sudo apt-get install libpq-dev"
echo "$ $cmd"
$cmd || exit 1

# client utilities (psql, createdb, pg_dump, etc.)
command -v psql >/dev/null || {
  cmd="sudo apt-get install postgresql-client"
  echo "$ $cmd"
  $cmd || exit 1
}

if [ "${DATABASE_INSTALL:-true}" = "true" ]; then
  # install server (not required if the server is running on another host/container)
  id -u postgres &> /dev/null || {
    echo "PostgreSQL server required!"
    bash script/confirm.bash 'Install PostgreSQL server' && {
      cmd="sudo apt-get install postgresql"
      echo "$ $cmd"
      $cmd
    } || exit 1
  }

  # setup user if required
  psql -U "$DATABASE_USERNAME" postgres -c '' &> /dev/null || {
    bash script/confirm.bash "Create new PostgreSQL user $DATABASE_USERNAME" && {
      cmd="sudo -u postgres createuser --superuser $DATABASE_USERNAME"
      echo "$ $cmd"
      $cmd
    } || exit 1
  }
fi

# setup database if required
if [[ $DATABASE ]] ; then
  psql -U "$DATABASE_USERNAME" "$DATABASE" -c '' &> /dev/null || {
    bash script/confirm.bash "Create new PostgreSQL database $DATABASE" && {
      cmd="sudo -u postgres createdb $DATABASE"
      echo "$ $cmd"
      $cmd
    } || exit 1
  }
fi

# setup test database if required
if [[ $TEST_DATABASE ]] ; then
  psql -U "$DATABASE_USERNAME" "$TEST_DATABASE" -c '' &> /dev/null || {
    bash script/confirm.bash "Create new PostgreSQL database $TEST_DATABASE" && {
      cmd="sudo -u postgres createdb $TEST_DATABASE"
      echo "$ $cmd"
      $cmd
    } || exit
  }
fi

