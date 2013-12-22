class ApplicationWorker
  extend Qless::Job::SupportsMiddleware

  def self.put(options = {})
    queue = options.delete(:queue) || default_queue
    job = $qless.queues[queue].put(self, options)

    $qless.queues[queue].pop.perform if Rails.env.test?

    job
  end

  protected
  def self.default_queue(queue = nil)
    @default_queue = (queue || @default_queue || 'default').to_s
  end
end
