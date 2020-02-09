#!/usr/bin/env bash

echo "Preparing to compile and install the V8 JavaScript Engine."
echo
echo "If this fails, visit https://v8.dev/docs/build and follow the instructions."
echo "This may take a while..."
echo
set -x

: Installing dependencies
sudo apt-get install python -y
sudo apt-get install git -y
sudo apt-get install wget -y

: Making temporary directory
build="$HOME/v8-build"
mkdir "$build"
cd "$build" || exit
# The build process creates things in $HOME (.vpython_cipd_cache and .vpython-root).
# Set $HOME to the build directory so they will be cleaned up.
HOME="$build"

: Installing depot_tools
git clone --depth 1 https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH="$PATH:$PWD/depot_tools"
gclient --version

: Getting V8 source code
mkdir v8
cd v8
fetch --no-history v8
cd v8

: Installing additional build dependencies
gclient sync --no-history
./build/install-build-deps.sh --no-syms --no-arm --no-chromeos-fonts --no-nacl

: Compiling V8
./tools/dev/v8gen.py x64.release -- v8_use_external_startup_data=false
ninja -C out.gn/x64.release d8

: Moving executable into place
sudo mv ./out.gn/x64.release/d8 "$ISOLATE_ROOT"/usr/local/bin/d8 && {

  : Cleaning up # only if mv succeeded, so user can inspect build errors
  rm -rf "$build"
}

set +x
echo "JavaScript V8 installed into $ISOLATE_ROOT/usr/local/bin/d8"
echo
