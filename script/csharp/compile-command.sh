#! /usr/bin/env bash

# This script does two things
#   - Redirects errors from stdout to stderr so that nztrain knows when compilation fails
#   - Supply .dll references to the csc command

# Print version and copyright by compiling nothing
/usr/bin/dotnet /usr/share/dotnet/sdk/3.1.101/Roslyn/bincore/csc.dll | \
# print the first line, which has compiler version info, to stdout
head -n 1 > /dev/stdout

# Actually compile:
# [dotnet] [csc] -reference:[stdlib.dll] [...passed in args...]
/usr/bin/dotnet /usr/share/dotnet/sdk/3.1.101/Roslyn/bincore/csc.dll \
-reference:/usr/share/dotnet/sdk/3.1.101/ref/netstandard.dll "$@" | \
# Remove the first 3 lines of output. The rest, if any, are errors.
tail -n +4 > /dev/stderr
