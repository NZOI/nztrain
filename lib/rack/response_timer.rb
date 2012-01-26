class Rack::ResponseTimer
  def initialize(app, options = {})
    @app = app
    @format = options[:format] || "%f"
  end
  
  def call(env)
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
    if @format.respond_to? :call
      responsetime = @format.call(@stop-@start)
    else
      responsetime = ($1 || @format) % (@stop-@start)
    end
    @response.each do |msg| # replace only last occurrence of $responsetime
      block.call(msg.gsub(/(.*)\$responsetime(?:\((.+)\))?(.*)/m,'\1' + responsetime + '\3'))
    end
  end
end

