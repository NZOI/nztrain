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

  def ajax_pagination(options = {})
    pagination = options[:pagination] || 'page' # by default the name of the pagination is 'page'
    partial = options[:partial] || pagination # default partial rendered is the name of the pagination
    reload = options[:reload]
    divoptions = { :id => "#{pagination}_paginated_section", :class => "paginated_section" }
    case reload.class.to_s
    when "String"
      divoptions["data-reload"] = reload
    when "Hash", "Array"
      divoptions["data-reload"] = reload.to_json
    end
    content_tag :div, divoptions do
      render partial
    end
  end
  def ajax_pagination_loadzone()
    content_tag :div, :class => "paginated_content", :style => "position: relative" do
      yield
    end
  end
end
