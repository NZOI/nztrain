# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake/dsl_definition'
require 'rake'

NZTrain::Application.load_tasks

namespace :qless do
  task :work => :environment do
    defined?(ActiveRecord::Base) and
      ActiveRecord::Base.connection.disconnect!
    $activerecord_connection = false
    require 'qless/job_reservers/ordered'
    require 'qless/worker'
    # The only required option is QUEUES; the
    # rest have reasonable defaults.
    queues = %w[judge].map { |name| $qless.queues[name] }
    job_reserver = Qless::JobReservers::Ordered.new(queues)
    worker = Qless::Workers::ForkingWorker.new(job_reserver, :num_workers => 2, :interval => 2).run
  end
end
