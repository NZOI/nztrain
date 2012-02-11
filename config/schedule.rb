# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end
job_type :cmd,  "cd :path && :task :output" # job to be run in the rails root path

every 1.day do
  rake "session:clean" # delete old sessions
  cmd "find public/uploads/tmp/* -mtime +1 -exec rm {} \\;" # delete old tmp uploads
  cmd "find public/uploads/tmp/* -type d -empty -delete" # delete empty directories in tmp directory (caused by deleting tmp uploads)
end

# Learn more: http://github.com/javan/whenever
