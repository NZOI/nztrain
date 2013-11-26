require 'sidekiq/web'

class SidekiqController < ApplicationController
  def default
    raise Authorization::AuthorizationError if current_user.nil? || !current_user.has_role?(:superadmin)
    env = request.env.merge("SCRIPT_NAME" => [request.script_name,controller_name].join('/'),
                            "PATH_INFO" => request.path_info.sub(/\A\/#{controller_name}/,''))
    status, headers, body = Sidekiq::Web.new.call(env)
    headers.delete("Content-Length") # so we can wrap our layout around everything
    response.headers.merge!(headers) # set the headers
    if headers["Content-Type"] =~ /^text\/html/ # wrap layout
      document = Nokogiri::HTML(serialize_body(body))
      content_for(:title, document.title)
      document.at_css("head").children.each do |tag|
        case tag.name
        when 'link', 'script'
          content_for(:head, tag.to_html.html_safe)
        end
      end
      content_for(:head, "<style>.navbar-fixed-top{position:static;}</style>".html_safe)
      render :status => status, :text => document.at_css("body").inner_html, :layout => true
    elsif body.respond_to?(:to_path)
      render :status => status, :file => body.to_path
    else
      render :status => status, :text => serialize_body(body)
    end
  end

  private
  def serialize_body(body)
    array = []
    body.each { |part| array << part}
    array.join
  end

  def view_context
    super.tap do |view|
      (@_content_for || {}).each do |name,content|
        view.content_for name, content
      end
    end
  end

  def content_for(name, content)
    @_content_for ||= {}
    if @_content_for[name].respond_to?(:<<)
      @_content_for[name] << content
    else
      @_content_for[name] = content
    end
  end

end
