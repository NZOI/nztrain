# NZTrain
[![Build Status](https://github.com/NZOI/nztrain/actions/workflows/ci.yml/badge.svg)](https://github.com/NZOI/nztrain/actions/workflows/ci.yml)
[![Coverage Status](https://coveralls.io/repos/github/NZOI/nztrain/badge.svg)](https://coveralls.io/github/NZOI/nztrain)
[![Code Climate](https://codeclimate.com/github/NZOI/nztrain.svg)](https://codeclimate.com/github/NZOI/nztrain)

## Installation
Run `script/install.bash` to install dependencies.

`script/update.bash` will pull changes from origin and recompile various things. This includes assets - assuming that it is for production purposes.

Both scripts depends on `script/install.cfg`, which is built using `script/install/config.bash` automatically. If `script/install.cfg` is incomplete (eg. new configuration is added), `script/install.bash` and `script/update.bash` will prompt for the new configurations required.

## Development Tools
- `spring` instead of `bundle exec` to keep a background copy of rails running, and avoid startup time.
- `unicorn` starts of a development server (instead of Webrick).

