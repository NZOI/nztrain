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

