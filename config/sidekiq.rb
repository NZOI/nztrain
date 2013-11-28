# Options here can still be overridden by cmd line args.
#   sidekiq -C config.yml
---
:verbose: false
:pidfile: ./tmp/pids/sidekiq.pid
:logfile: ./log/sidekiq.log
:concurrency: 4
:queues:
  - default
