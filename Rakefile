# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path("../config/application", __FILE__)
require "rake/dsl_definition"
require "rake"

NZTrain::Application.load_tasks

namespace :qless do
  task :setup do
    Rails.env = ARGV[1] if ARGV[1]
  end

  task work: [:setup, :environment] do
    require "qless/job_reservers/ordered"
    require "qless/worker"

    defined?(ActiveRecord::Base) and
      ActiveRecord::Base.connection.disconnect!

    module ActiveRecordReconnect
      def after_fork
        ActiveRecord::Base.establish_connection
      end
    end

    Qless::Workers::ForkingWorker.send(:include, ActiveRecordReconnect)

    # The only required option is QUEUES; the
    # rest have reasonable defaults.
    queues = %w[judge queue stalejudge importer].map { |name| $qless.queues[name] }
    job_reserver = Qless::JobReservers::Ordered.new(queues)

    worker = Qless::Workers::ForkingWorker.new(job_reserver, num_workers: 2, interval: 2, log_level: Logger::INFO).run
  end
end
