class Rack::ResponseTimer
  def initialize(app, options = {})
    @app = app
    @format = options[:format] || "%f"
  end
  
  def call(env)
    @start = Time.now
    status, headers, @response = @app.call(env)
    @stop = Time.now
    [status, headers, self]
  end

  def each(&block)
    if @format.respond_to? :call
      responsetime = @format.call(@stop-@start)
    else
      responsetime = ($1 || @format) % (@stop-@start)
    end
    @response.each do |msg|
      block.call(msg.gsub(/(.*)\$responsetime(?:\((.+)\))?(.*)/m,'\1' + responsetime + '\3'))
    end
  end
end

