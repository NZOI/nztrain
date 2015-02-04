class ProblemPresenter < ApplicationPresenter
  presents :problem
  delegate :name, to: :problem

  present_resource_links
  present_owner_link

  def avatar
    h.tag :img, :src => user.avatar_url
  end

  def linked_name
    h.link_to problem.name, problem
  end

  def input
    problem.input || "stdin"
  end

  def output
    problem.output || "stdout"
  end

  def memory_limit
    "#{problem.memory_limit} MB"
  end

  def time_limit
    "#{problem.time_limit} s"
  end

  def progress_bar
    h.progress_bar(problem.score) if problem.score
  end

  def test_status
    colour = case problem.test_status
    when -1; "#FF0000"
    when -2; "#FF8000"
    when 0; "#808080"
    when 1; "#FFFF00"
    when 2; "#80FF00"
    when 3; "#00C000"
    else; "#808080"
    end
    h.content_tag :div, " ", :style => "border-radius: 50%; width: 15px; height: 15px; background-color: #{colour}; display: inline-block"
  end
end
