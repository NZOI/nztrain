#!/usr/bin/env bash

cd `dirname $0`/../..

set -x

: Installing .NET Core for C#
# https://docs.microsoft.com/en-us/dotnet/core/install/linux-package-manager-ubuntu-1604

: Downloading package info from Microsoft
UBUNTU_VERSION=$(chroot "$ISOLATE_ROOT" lsb_release --release --short)
chroot "$ISOLATE_ROOT" wget -q "https://packages.microsoft.com/config/ubuntu/${UBUNTU_VERSION}/packages-microsoft-prod.deb" -O /tmp/packages-microsoft-prod.deb
chroot "$ISOLATE_ROOT" dpkg -i /tmp/packages-microsoft-prod.deb
chroot "$ISOLATE_ROOT" rm /tmp/packages-microsoft-prod.deb
chroot "$ISOLATE_ROOT" add-apt-repository universe
chroot "$ISOLATE_ROOT" apt-get install -y apt-transport-https
chroot "$ISOLATE_ROOT" apt-get update

: Installing dotnet 3.1
export DOTNET_CLI_TELEMETRY_OPTOUT=1
chroot "$ISOLATE_ROOT" apt-get install -y dotnet-sdk-3.1

: Creating runtime config file
# The dotnet command requires executables to have a corresponding file
# [appname].runtimeconfig.json that specifies which runtime framework to use.
# We create such a file and set it using the --runtimeconfig option.
# https://stackoverflow.com/questions/46065777/is-it-possible-to-compile-a-single-c-sharp-code-file-with-the-net-core-roslyn-c
RUNTIMECONFIG_PATH="$ISOLATE_ROOT/usr/share/dotnet-runtimeconfig.json"  # used in the interpreter command

# Compute the .NET Core Runtime version from the .NET Core SDK version
# The major and minor versions are the same (https://docs.microsoft.com/en-us/dotnet/core/versions/).
# The patch version should be set to 0 (https://github.com/dotnet/designs/blob/master/accepted/runtime-binding.md).
DOTNET_FW_VERSION=$(chroot "$ISOLATE_ROOT" dotnet --version | sed 's/\.[0-9]\+$/.0/') \
  envsubst < script/install/dotnet/dotnet-runtimeconfig-template.json > "$RUNTIMECONFIG_PATH"

: Copying shell scripts into place

cp "script/install/dotnet/dotnet-csc" "$ISOLATE_ROOT/usr/local/bin"
cp "script/install/dotnet/dotnet-exec" "$ISOLATE_ROOT/usr/local/bin"

set +x
echo ".NET Core (C#) was installed"
