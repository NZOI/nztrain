#!/usr/bin/env bash

cd `dirname $0`/..

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

mount -o bind /proc "$ISOLATE_ROOT/proc"

chroot "$ISOLATE_ROOT"

umount "$ISOLATE_ROOT/proc"

