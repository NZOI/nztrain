#!/bin/bash

# pass in config file to specify runtime version
dotnet exec --runtimeconfig /usr/share/dotnet-config.json "$@"

exit ${PIPESTATUS[0]}
