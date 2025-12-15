module ScoringMethods
  # Calculate's the score for a problem based on a list of submissions
  # The score is determined using the correct scoring method
  # Returns [the score (0..1), the number of attempts needed to get that score, the last submission that earned points]
  def self.score_problem_submissions(problem, submissions)
    case problem.scoring_method
    when "subtask_scoring"
      score_with_subtask_scoring(problem, submissions)
    when "max_submission_scoring"
      score_with_max_submission_scoring(submissions)
    else
      raise "Unknown scoring method: #{problem.scoring_method}"
    end
  end

  def self.score_with_subtask_scoring(problem, submissions)
    if submissions.empty?
      return nil, nil, nil
    end

    testsets = problem.test_sets
    max_points_on_testset = {}
    test_set_values = {}

    # Maximum number of points possible on this problem (sum of testset points)
    max_points = 0
    testsets.each do |testset|
      max_points_on_testset[testset.id] = 0
      test_set_values[testset.id] = testset.points
      max_points += testset.points
    end

    submissions = submissions.order("created_at ASC")

    best_submission = submissions.first
    attempt = 1

    submissions.each_with_index do |submission, idx|
      improved_score = false

      submission.fast_judge_data.test_sets.each do |(test_set_id, set_data)|
        if test_set_values.has_key?(test_set_id)
          score_from_test_set = test_set_values[test_set_id] * set_data.evaluation
          if score_from_test_set > max_points_on_testset[test_set_id]
            max_points_on_testset[test_set_id] = score_from_test_set
            improved_score = true
          end
        end
      end

      if improved_score
        best_submission = submission
        attempt = idx + 1
      end
    end

    total_points = max_points_on_testset.values.sum
    score = max_points == 0 ? 0 : total_points / max_points
    [score, attempt, best_submission]
  end

  def self.score_with_max_submission_scoring(submissions)
    if submissions.empty?
      return nil, nil, nil
    end

    submission = submissions.order("evaluation DESC, created_at ASC").first
    attempt = submissions.where("created_at <= ?", submission.created_at).count
    score = submission.points.nil? || submission.maximum_points == 0 ? 0 : submission.points / submission.maximum_points
    [score, attempt, submission]
  end
end
