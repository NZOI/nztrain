#!/usr/bin/env bash

# option to set another source(origin) and branch(master)

echo '$ git pull'
git pull | sed -e 's/^/   /g;' | cat

