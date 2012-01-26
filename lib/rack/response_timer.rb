class Rack::ResponseTimer
  def initialize(app)
    @app = app
  end
  
  def call(env)
    dup._call(env) # making copy for thread-safety (so we can modify instance variables)
  end

  def _call(env)
    @start = Time.now
    @status, @headers, @response = @app.call(env)
    @stop = Time.now
    if @headers["Content-Type"].to_s.include? "text/html"
      [@status, @headers, self] # allow injection of response time
    else
      [@status, @headers, @response] # no modification if not html
    end
  end

  def each(&block)
    # note, we are replacing $responsetime with %13.2f, so that the padding with spaces doesn't change the @headers["Content-Length"]
    responsetime = "%13.2f" % (@stop-@start)
    @response.each do |msg| # replace only last occurrence of $responsetime
      block.call(msg.gsub(/(.*)\$responsetime(?:\((.+)\))?(.*)/m,'\1' + responsetime + '\3'))
    end
  end
end

