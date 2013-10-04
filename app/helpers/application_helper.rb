module ApplicationHelper
  def present(object, klass = nil)
    klass ||= begin
      klass = object.class
      klass = object.first.class if klass == Array
      klass = object.to_a.first.class if klass == ActiveRecord::Relation
      "#{klass}Presenter".constantize
    end
    presenter = klass.new(object, self)
    yield presenter if block_given?
    presenter
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
end
