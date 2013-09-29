#!/usr/bin/env bash

# if AUTOCONFIRM environment variable set, auto-confirm
if [[ "$AUTOCONFIRM" ]] ; then exit 0 ; fi
if [[ -z "$DEFAULT" ]] ; then DEFAULT=0 ; fi

if [[ "$DEFAULT" = "0" ]] ; then
  read -p "$1 [Y/n]? " -n 1 -r
else
  read -p "$1 [y/N]? " -n 1 -r
fi

if [[ -n "$REPLY" ]] ; then echo ; fi
if [[ -n "$REPLY" ]] ; then # not empty
  if [[ $REPLY =~ ^[Yy]?$ ]] ; then exit 0
  else exit 1
  fi
else
  exit $DEFAULT
fi
