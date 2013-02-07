#!/usr/bin/env bash

echo '$ rake assets:precompile'
bundle exec rake assets:precompile | sed -e 's/^/   /g;' | cat # sed to indent output

