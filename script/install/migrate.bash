#!/usr/bin/env bash
set -o pipefail # to detect failure in 'bundle ... | sed ...' (see 'man bash')

lastupdate=`cat script/update.time` # get time of last update

lastmodified=`find db/migrate/ -printf '%T+\n' | sort -r | head -n1`
if [[ "$lastupdate" < "$lastmodified" ]] ; then
  echo '$ rake db:migrate'
  bundle exec rake db:migrate | sed -e 's/^/   /g;' | cat || exit 1 # sed to indent output
fi

lastmodified=`find db/seeds.rb -printf '%T+\n' | sort -r | head -n1`
if [[ "$lastupdate" < "$lastmodified" ]] ; then
  echo '$ rake db:seed'
  bundle exec rake db:seed | sed -e 's/^/   /g;' | cat || exit 1 # sed to indent output
fi
