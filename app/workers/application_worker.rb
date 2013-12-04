class ApplicationWorker
  extend Qless::Job::SupportsMiddleware

  def self.put(options = {})
    job = $qless.queues[default_queue].put(self, options)

    $qless.queues[default_queue].pop.perform if Rails.env.test?

    job
  end

  protected
  def self.default_queue(queue = nil)
    @default_queue = (queue || @default_queue || 'default').to_s
  end
end
