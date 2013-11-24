# Options here can still be overridden by cmd line args.
#   sidekiq -C config.yml
---
:verbose: false
:pidfile: ./tmp/pids/sidekiq.pid
:concurrency: 10
:queues:
  - [default, 5]
#  - [often, 7]
#  - [seldom, 3]
