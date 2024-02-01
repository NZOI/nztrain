#!/usr/bin/env bash

cmd="sudo apt-get install wkhtmltopdf xvfb"
echo "$ $cmd"
$cmd || exit 1
