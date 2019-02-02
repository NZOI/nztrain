#!/usr/bin/env bash
set -o pipefail # to detect failure in 'bundle ... | sed ...' (see 'man bash')

echo '$ rake assets:precompile'
bundle exec rake assets:precompile | sed -e 's/^/   /g;' | cat || exit 1 # sed to indent output

