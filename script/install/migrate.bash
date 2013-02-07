#!/usr/bin/env bash

echo '$ rake db:migrate'
bundle exec rake db:migrate | sed -e 's/^/   /g;' | cat # sed to indent output

echo '$ rake db:seed'
bundle exec rake db:seed | sed -e 's/^/   /g;' | cat # sed to indent output

