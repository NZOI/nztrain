#!/usr/bin/env bash

read version

larger=`echo -e "$version\n$1" | sort -V | tail -1`
if [[ $version != $larger ]] ; then
  exit 1
fi
if [[ $2 ]] ; then
  smaller=`echo -e "$version\n$2" | sort -V | head -1`
  if [[ $version != $smaller ]] ; then
    exit 1
  fi
fi


