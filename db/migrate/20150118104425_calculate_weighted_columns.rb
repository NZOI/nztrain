require "bigdecimal"

class CalculateWeightedColumns < ActiveRecord::Migration
  def up
    maxpoints = []

    i = 0
    Submission.find_each do |s|
      next if s.judge_log.nil?
      judge_log = JSON.parse(s.judge_log)
      next if judge_log["evaluation"].nil?
      s.evaluation = judge_log["evaluation"].to_f
      s.maximum_points = maxpoints[s.problem_id] ||= TestSet.where(problem_id: s.problem_id).sum(:points)
      s.points = BigDecimal(s.evaluation * s.maximum_points + Float::EPSILON, 10)

      s.save
      i += 1
      puts "Submissions calculated: #{i}" if i % 100 == 0
      sleep(0.1)
    end

    i = 0
    ProblemSet.find_each do |s|
      s.finalized_contests_count = s.contests.where.not(finalized_at: nil).count
      s.save
      i += 1
      puts "Problem Sets calculated: #{i}" if i % 100 == 0
      sleep(0.1)
    end
  end

  def down
  end
end
