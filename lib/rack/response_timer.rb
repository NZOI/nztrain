class Rack::ResponseTimer
  def initialize(app, options = {})
    @app = app
    @format = options[:format] || "%f"
  end
  
  def call(env)
    @start = Time.now
    status, headers, @response = @app.call(env)
    @stop = Time.now
    #returning @app.call(env) do |response|
    #  response.last.body.gsub! /\$responsetime(?:\((.+)\))?/ do
    #    diff = stop - start
    #    if @format.respond_to? :call
    #      @format.call(diff)
    #    else
    #      ($1 || @format) % diff
    #    end
    #  end
    #end
    [status, headers, self]
  end

  def each(&block)
    @response.each do |msg|
      block.call(msg.gsub /\$responsetime(?:\((.+)\))?/ do
        if @format.respond_to? :call
          @format.call(@stop-@start)
        else
          ($1 || @format) % (@stop-@start)
        end
      end)
    end
  end
end

