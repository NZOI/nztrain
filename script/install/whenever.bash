#!/usr/bin/env bash

lastupdate=`cat script/update.time` # get time of last update

lastmodified=`find config/schedule.rb config/backup.yml -printf '%T+\n' | sort -r | head -n1`
if [[ "$lastupdate" < "$lastmodified" ]] ; then
  echo '$ whenever --update-crontab '`basename \`pwd\``
  `bundle list whenever`/bin/whenever --update-crontab `basename \`pwd\``
fi

