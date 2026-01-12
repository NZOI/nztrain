class CreateContestsCountSubmissionsView < ActiveRecord::Migration[4.2]
  def self.up
    execute "CREATE VIEW contests_count_submissions AS SELECT contest_relations.contest_id, submissions.user_id, submissions.problem_id, COUNT(*) AS count FROM contests JOIN contest_relations ON contests.id = contest_relations.contest_id JOIN contests_problems ON contests_problems.contest_id = contests.id JOIN submissions ON contest_relations.user_id = submissions.user_id AND submissions.problem_id = contests_problems.problem_id WHERE submissions.created_at BETWEEN contests.start_time AND contests.end_time GROUP BY contest_relations.contest_id, submissions.user_id, submissions.problem_id;"
  end

  def self.down
    execute "DROP VIEW contests_count_submissions"
  end
end
