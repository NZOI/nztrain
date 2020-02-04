#!/usr/bin/env bash

echo "Preparing to compile and install the V8 JavaScript Engine."
echo
echo "If this fails, visit https://v8.dev/docs/build and follow the instructions."
echo "This may take a while..."
echo
set -x

: Installing dependencies
apt-get install python -y
apt-get install git -y
apt-get install wget -y

: Making temporary directory
mkdir ~/v8-build
cd ~/v8-build

: Installing depot_tools
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH="$PATH:$PWD/depot_tools"
gclient

: Getting V8 source code
mkdir v8
cd v8
fetch v8
cd v8

: Installing additional build dependencies
gclient sync
./build/install-build-deps.sh

: Compiling V8
./tools/dev/v8gen.py x64.release -- v8_use_external_startup_data=false
ninja -C out.gn/x64.release d8

: Moving executable into place
sudo mv ./out.gn/x64.release/d8 "$ISOLATE_ROOT"/usr/local/bin/d8 && {

  : Cleaning up # only if mv succeeded, so user can inspect build errors
  cd ~
  rm -rf ~/v8-build
}

set +x
echo "JavaScript V8 installed into $ISOLATE_ROOT/usr/local/bin/d8"
echo
