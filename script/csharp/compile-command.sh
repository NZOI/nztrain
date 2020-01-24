#!/bin/bash

# This script does two things
#   1. Redirects all output to stderr
#   2. Supplies .dll references to the csc command

# Actually compile:
# [dotnet] [csc] -reference:[stdlib.dll] [...passed in args...]
VERSION=$(dotnet --version)
/usr/bin/dotnet "/usr/share/dotnet/sdk/"$VERSION"/Roslyn/bincore/csc.dll" \
-reference:"/usr/share/dotnet/sdk/"$VERSION"/ref/netstandard.dll" "$@" 1>&2

exit ${PIPESTATUS[0]}
