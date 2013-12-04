module GCWorkerMiddleware
  def around_perform(job)
    super
    GC.start
  end
end
