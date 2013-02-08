#!/usr/bin/env bash

# if AUTOCONFIRM environment variable set, auto-confirm
if [[ "$AUTOCONFIRM" ]] ; then exit 0 ; fi

read -p "$1 [Y/n]? " -n 1 -r
if [[ -n "$REPLY" ]] ; then echo ; fi
if [[ $REPLY =~ ^[Yy]?$ ]] ; then exit 0
else exit 1
fi

