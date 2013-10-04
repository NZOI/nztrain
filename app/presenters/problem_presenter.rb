class ProblemPresenter < BasePresenter
  presents :problem
  delegate :title, to: :user

  present_resource_links
  present_owner_link

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
