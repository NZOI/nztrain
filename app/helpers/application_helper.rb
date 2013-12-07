module ApplicationHelper
  def y(string)
    return string if !%w{yes no}.include?(string) && string =~ (/\A[[:alpha:]\.][[:alnum:]\.]*\z/) # safe for unquoted use
    string.to_json # JSON is a subset of YAML
  end

  def progress_bar(percent, link = nil)
    unless percent.nil?
      percent = percent.to_i
      text = percent.to_s + '%'
    else
      text = '-'
    end
    if link != nil
      text = link_to(text,link,{:class => "progress_link", :style => "display: block; width: 100%;"})
    end
    if percent.nil?
      colour = "rgb(192,192,192)"
      percent = 0;
    elsif percent <= 50 # make a nice spectrum of colours
      colour = "rgb(255,#{(percent*255/50).to_i},0)"
    else
      colour = "rgb(#{255-((percent-50)*255/50).to_i},#{255-((percent-50)*60/50).to_i},0)"
    end
    raw "<div style=\"display: inline-block; vertical-align: middle; position: relative; height: 18px; width: 100px; border: 1px #{colour} solid;\"><div style=\"height: 100%; width: #{percent}%; background-color: #{colour}\"></div><div style=\"position: absolute; top: 0; left: 0; width: 100%; height: 100%; text-align: center; font-size: small; text-shadow: 1px 1px #FFFFFF;\">#{text}</div></div>"
  end

  def in_su?
    session[:su] && !session[:su].empty?
  end

  def icon name
    content_tag :i, "", :class => "icon-#{name}"
  end

  def toolbox_push text, link, options = {}
    if text.class == Symbol
      newopts = toolbox_options text
      text = newopts[:text] || text.to_s.capitalize
      options.reverse_merge! newopts.except(:text)
    end
    text = icon(options[:icon]) + text if options.has_key? :icon
    link_options = options.except(:icon, :color)
    content_for :toolbox do
      content_tag :li, :class => options[:color] do
        link_to link, link_options do
          text
        end
      end
    end
  end

  def toolbox_options symbol
    map = {
      :back => { :icon => :back, :color => :blue },
      :delete => { :icon => :trash, :color => :red, :method => :delete, :data => { :confirm => "Are you sure?" } },
      :edit => { :icon => :edit, :color => :blue },
      :new => { :icon => :new, :color => :blue },
      :apply => { :icon => :mail, :color => :blue, :method => :put },
      :join => { :icon => :login, :color => :green, :method => :put },
      :leave => { :icon => :logout, :color => :red, :method => :put }
    }
    map[symbol]
  end
end
