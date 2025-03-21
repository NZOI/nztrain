class CreateContestsMaxScoreScoreboardView < ActiveRecord::Migration
  def self.up
    case ActiveRecord::Base.connection.adapter_name
    when 'SQLite'
      execute "CREATE VIEW contests_max_score_scoreboard AS SELECT contest_relations.contest_id, contest_relations.user_id, COALESCE(SUM(score),0) AS total_score, STRFTIME('%s',SUBSTR(COALESCE(MAX(submissions_score.created_at),MIN(contest_relations.created_at)),0,27)) - STRFTIME('%s',SUBSTR(MIN(contest_relations.created_at),0,27)) AS time_taken FROM contest_relations LEFT JOIN contests_max_score_submissions AS submissions_score ON submissions_score.user_id = contest_relations.user_id AND contest_relations.contest_id = submissions_score.contest_id AND submissions_score.score > 0 GROUP BY contest_relations.user_id, contest_relations.contest_id ORDER BY total_score DESC, time_taken;"
    else
      execute "CREATE VIEW contests_max_score_scoreboard AS SELECT contest_relations.contest_id, contest_relations.user_id, COALESCE(SUM(score),0) AS total_score, COALESCE(MAX(submissions_score.created_at),MIN(contest_relations.created_at)) - MIN(contest_relations.created_at) AS time_taken, RANK() OVER (PARTITION BY contest_relations.contest_id ORDER BY COALESCE(SUM(score),0) DESC, COALESCE(MAX(submissions_score.created_at),MIN(contest_relations.created_at)) - MIN(contest_relations.created_at) ASC) AS rank FROM contest_relations LEFT JOIN contests_max_score_submissions AS submissions_score ON submissions_score.user_id = contest_relations.user_id AND contest_relations.contest_id = submissions_score.contest_id AND submissions_score.score > 0 GROUP BY contest_relations.user_id, contest_relations.contest_id;"
    end
  end

  def self.down
    execute "DROP VIEW contests_max_score_scoreboard"
  end
end
