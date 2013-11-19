#!/usr/bin/env bash

cd `dirname $0`/../..

source script/install.cfg

update=false
# process script options
for ARG in "$@"
do
    case $ARG in
    "--update")
        update=true
        ;;
    *)
        ;;
    esac
done

SUITE=precise

new_debootstrap=false

if [[ "$ISOLATE_ROOT" != "/" ]] && [[ ! -d "$ISOLATE_ROOT" ]]; then
  new_debootstrap=true
  apt-get install debootstrap

  mkdir "$ISOLATE_ROOT" -p

  # prompt user before debootstrap
  debootstrap $SUITE "$ISOLATE_ROOT" http://archive.ubuntu.com/ubuntu

  # add sources
  echo deb http://archive.ubuntu.com/ubuntu/ $SUITE-updates main restricted >> /srv/chroot/nztrain/etc/apt/sources.list
  echo deb http://archive.ubuntu.com/ubuntu/ $SUITE universe >> /srv/chroot/nztrain/etc/apt/sources.list
  echo deb http://security.ubuntu.com/ubuntu $SUITE-security main restricted >> /srv/chroot/nztrain/etc/apt/sources.list
  echo deb http://nz.archive.ubuntu.com/ubuntu/ $SUITE multiverse >> /srv/chroot/nztrain/etc/apt/sources.list
  echo deb-src http://nz.archive.ubuntu.com/ubuntu/ $SUITE multiverse >> /srv/chroot/nztrain/etc/apt/sources.list
  echo deb http://nz.archive.ubuntu.com/ubuntu/ $SUITE-updates multiverse >> /srv/chroot/nztrain/etc/apt/sources.list

  # link /etc/resolv.conf
  ln --force /etc/resolv.conf "$ISOLATE_ROOT/etc/resolv.conf"
fi

if ${update:=true} || ${new_debootstrap:=true} ; then
  chroot "$ISOLATE_ROOT" apt-get update
fi

chroot_install="$ chroot \"$ISOLATE_ROOT\" apt-get install"

echo "$chroot_install build-essential"
chroot "$ISOLATE_ROOT" apt-get install build-essential # C/C++ (g++, gcc)

echo "$chroot_install ruby"
chroot "$ISOLATE_ROOT" apt-get install ruby # Ruby (ruby)

echo "$chroot_install ghc6"
chroot "$ISOLATE_ROOT" apt-get install ghc6 # Haskell (ghc)

if [ ! -f "$ISOLATE_ROOT/usr/bin/cint.rb" ] ; then
  cmd="cp `dirname $0`/cint.rb $ISOLATE_ROOT/usr/bin"
  echo "$cmd"
  $cmd

  cmd="chmod 0755 $ISOLATE_ROOT/usr/bin/cint.rb"
  echo "$cmd"
  $cmd
fi
# let user know that chroot installs are finished

