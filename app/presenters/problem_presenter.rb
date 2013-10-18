class ProblemPresenter < ApplicationPresenter
  presents :problem
  delegate :title, to: :problem

  present_resource_links
  present_owner_link

  label :linked_title => "Title", :linked_owner => "Owner", :progress_bar => "Progress"

  def avatar
    h.tag :img, :src => user.avatar_url
  end

  def linked_title
    h.link_to problem.title, problem
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

end
