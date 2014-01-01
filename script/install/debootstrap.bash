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

chroot_cmd="$ chroot \"$ISOLATE_ROOT\""
chroot_install="$chroot_cmd apt-get install"

echo "$chroot_cmd apt-get update"
chroot "$ISOLATE_ROOT" apt-get update

echo "$chroot_install software-properties-common"
chroot "$ISOLATE_ROOT" apt-get install software-properties-common # provides add-apt-repository

# only for <= 12.04
echo "$chroot_install python-software-properties"
chroot "$ISOLATE_ROOT" apt-get install python-software-properties # provides add-apt-repository

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

# gcc 4.8.1 on Precise (will not be needed when we use trusty tahr)
echo "$chroot_cmd add-apt-repository ppa:ubuntu-toolchain-r/test"
chroot "$ISOLATE_ROOT" add-apt-repository ppa:ubuntu-toolchain-r/test

echo "$chroot_cmd apt-get update"
chroot "$ISOLATE_ROOT" apt-get update

echo "$chroot_cmd apt-get install gcc-4.8"
chroot "$ISOLATE_ROOT" apt-get install gcc-4.8

echo "$chroot_cmd apt-get install g++-4.8"
chroot "$ISOLATE_ROOT" apt-get install g++-4.8

echo "$chroot_cmd update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 50"
chroot "$ISOLATE_ROOT" update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.8 50

echo "$chroot_cmd update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.8 50"
chroot "$ISOLATE_ROOT" update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.8 50
# gcc 4.8.1 done

# let user know that chroot installs are finished

