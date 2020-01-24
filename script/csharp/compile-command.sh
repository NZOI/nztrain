#!/bin/sh

# This script does two things
#   1. Redirects all output to stderr
#   2. Supplies .dll references to the csc command

# Actually compile:
# [dotnet] [csc] -reference:[stdlib.dll] [...passed in args...]
/usr/bin/dotnet /usr/share/dotnet/sdk/3.1.101/Roslyn/bincore/csc.dll \
-reference:/usr/share/dotnet/sdk/3.1.101/ref/netstandard.dll "$@" 1>&2

exit ${PIPESTATUS[0]}
