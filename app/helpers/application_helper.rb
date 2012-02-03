module ApplicationHelper
  def progress_bar(percent, link = nil)
    percent = percent.to_i
    if link != nil
      text = link_to((percent.to_s + '%'),link,{:class => "progress_link", :style => "display: block; width: 100%;"})
    else
      text = percent.to_s + '%'
    end
    if percent <= 50 # make a nice spectrum of colours
      colour = "rgb(255,#{(percent*255/50).to_i},0)"
    else
      colour = "rgb(#{255-((percent-50)*255/50).to_i},#{255-((percent-50)*60/50).to_i},0)"
    end
    raw "<div style=\"display: inline-block; vertical-align: middle; position: relative; height: 18px; width: 100px; border: 1px #{colour} solid;\"><div style=\"height: 100%; width: #{percent}%; background-color: #{colour}\"></div><div style=\"position: absolute; top: 0; left: 0; width: 100%; height: 100%; text-align: center; font-size: small; text-shadow: 1px 1px #FFFFFF;\">#{text}</div></div>"
  end

  def in_su?
    session[:su] && !session[:su].empty?
  end

  # TODO FIXME escape_javascript override
  # https://github.com/rails/rails/pull/1558
  # REMOVE THIS MONKEY PATCH WHEN RAILS UPGRADED
  JS_ESCAPE_MAP	=	{ '\\' => '\\\\', '</' => '<\/', "\r\n" => '\n', "\n" => '\n', "\r" => '\n', '"' => '\\"', "'" => "\\'" } 
  def escape_javascript(javascript)
    if javascript
      javascript.gsub(/(\\|<\/|\r\n|[\n\r"'])/) { |s| JS_ESCAPE_MAP[s] }
    else
      ''
    end 
  end
end
