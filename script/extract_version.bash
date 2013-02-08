#!/usr/bin/env bash

read line
echo `echo $line | sed 's/[^0-9.-]*\([0-9.-]*\).*/\1/'`

