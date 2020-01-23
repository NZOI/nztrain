#!/bin/sh

# pass in config file to specify runtime version
dotnet exec --runtimeconfig /usr/share/dotnet-config.json "$@"
