class CreateContestScores < ActiveRecord::Migration[4.2]
  def up
    # table to cache submission score for each problem/user (of all submissions that have been created)
    # however, this score may differ from actual submission score if it gets rejudged after a contest has been sealed
    create_table :contest_scores do |t|
      t.references :contest_relation, null: false
      t.references :problem, null: false
      t.integer :score
      t.integer :attempts
      t.integer :attempt
      t.references :submission

      t.datetime :updated_at # since tuples are generated automatically, created_at is not useful
    end
    add_index :contest_scores, [:contest_relation_id, :problem_id]

    # columns in contest_relations to cache important data
    add_column :contest_relations, :score, :integer, null: false, default: 0 # column to cache total score
    add_column :contest_relations, :time_taken, :float, limit: 53, null: false, default: 0 # column to cache time taken
    add_index :contest_relations, [:contest_id, :score, :time_taken], order: {contest_id: :asc, score: :desc, time_taken: :asc} # index to make it easy to get scores in sorted order for a specific contest

    # populate cache table for current contests
    Contest.find_each do |contest|
      contest.update_contest_scores
    end

    # delete old DB view objects
    execute "DROP VIEW contests_count_submissions"
    execute "DROP VIEW contests_latest_scoreboard"
    execute "DROP VIEW contests_max_score_scoreboard"
    execute "DROP VIEW contests_latest_submissions"
    execute "DROP VIEW contests_max_score_submissions"
  end

  def down
    drop_table :contest_scores
    remove_column :contest_relations, :score
    remove_column :contest_relations, :time_taken

    # recreate DB view objects
    case ActiveRecord::Base.connection.adapter_name
    when "SQLite"
      execute "CREATE VIEW contests_max_score_submissions AS SELECT submissions.id, submissions.score as score, submissions.user_id, submissions.problem_id, submissions.created_at, submissions.updated_at, contest_relations.contest_id FROM contests JOIN contest_relations ON contests.id = contest_relations.contest_id JOIN problem_sets ON contests.problem_set_id = problem_sets.id JOIN problem_sets_problems ON problem_sets_problems.problem_set_id = problem_sets.id JOIN submissions ON contest_relations.user_id = submissions.user_id AND submissions.problem_id = problem_sets_problems.problem_id WHERE submissions.created_at BETWEEN contests.start_time AND contests.end_time GROUP BY contests.id, submissions.user_id, submissions.problem_id ORDER BY contests.id, submissions.user_id, submissions.problem_id, score DESC, submissions.created_at ASC;"
    else
      execute "CREATE VIEW contests_max_score_submissions AS SELECT DISTINCT ON (contests.id, submissions.user_id, submissions.problem_id) submissions.id, submissions.score as score, submissions.user_id, submissions.problem_id, submissions.created_at, submissions.updated_at, contest_relations.contest_id FROM contests JOIN contest_relations ON contests.id = contest_relations.contest_id JOIN problem_sets ON contests.problem_set_id = problem_sets.id JOIN problem_sets_problems ON problem_sets_problems.problem_set_id = problem_sets.id JOIN submissions ON contest_relations.user_id = submissions.user_id AND submissions.problem_id = problem_sets_problems.problem_id WHERE submissions.created_at BETWEEN contests.start_time AND contests.end_time ORDER BY contests.id, submissions.user_id, submissions.problem_id, score DESC, submissions.created_at ASC;"
    end
    case ActiveRecord::Base.connection.adapter_name
    when "SQLite"
      execute "CREATE VIEW contests_latest_submissions AS SELECT submissions.id, submissions.score as score, submissions.user_id, submissions.problem_id, submissions.created_at, submissions.updated_at, contest_relations.contest_id FROM contests JOIN contest_relations ON contests.id = contest_relations.contest_id JOIN problem_sets ON contests.problem_set_id = problem_sets.id JOIN problem_sets_problems ON problem_sets_problems.problem_set_id = problem_sets.id JOIN submissions ON contest_relations.user_id = submissions.user_id AND submissions.problem_id = problem_sets_problems.problem_id WHERE submissions.created_at BETWEEN contests.start_time AND contests.end_time GROUP BY contests.id, submissions.user_id, submissions.problem_id ORDER BY contests.id, submissions.user_id, submissions.problem_id, submissions.created_at DESC;"
    else
      execute "CREATE VIEW contests_latest_submissions AS SELECT DISTINCT ON (contests.id, submissions.user_id, submissions.problem_id) submissions.id, submissions.score as score, submissions.user_id, submissions.problem_id, submissions.created_at, submissions.updated_at, contest_relations.contest_id FROM contests JOIN contest_relations ON contests.id = contest_relations.contest_id JOIN problem_sets ON contests.problem_set_id = problem_sets.id JOIN problem_sets_problems ON problem_sets_problems.problem_set_id = problem_sets.id JOIN submissions ON contest_relations.user_id = submissions.user_id AND submissions.problem_id = problem_sets_problems.problem_id WHERE submissions.created_at BETWEEN contests.start_time AND contests.end_time ORDER BY contests.id, submissions.user_id, submissions.problem_id, submissions.created_at DESC;"
    end
    case ActiveRecord::Base.connection.adapter_name
    when "SQLite"
      execute "CREATE VIEW contests_max_score_scoreboard AS SELECT contest_relations.contest_id, contest_relations.user_id, COALESCE(SUM(score),0) AS total_score, STRFTIME('%s',SUBSTR(COALESCE(MAX(submissions_score.created_at),MIN(contest_relations.created_at)),0,27)) - STRFTIME('%s',SUBSTR(MIN(contest_relations.created_at),0,27)) AS time_taken FROM contest_relations LEFT JOIN contests_max_score_submissions AS submissions_score ON submissions_score.user_id = contest_relations.user_id AND contest_relations.contest_id = submissions_score.contest_id AND submissions_score.score > 0 GROUP BY contest_relations.user_id, contest_relations.contest_id ORDER BY total_score DESC, time_taken;"
    else
      execute "CREATE VIEW contests_max_score_scoreboard AS SELECT contest_relations.contest_id, contest_relations.user_id, COALESCE(SUM(score),0) AS total_score, COALESCE(MAX(submissions_score.created_at),MIN(contest_relations.created_at)) - MIN(contest_relations.created_at) AS time_taken, RANK() OVER (PARTITION BY contest_relations.contest_id ORDER BY COALESCE(SUM(score),0) DESC, COALESCE(MAX(submissions_score.created_at),MIN(contest_relations.created_at)) - MIN(contest_relations.created_at) ASC) AS rank FROM contest_relations LEFT JOIN contests_max_score_submissions AS submissions_score ON submissions_score.user_id = contest_relations.user_id AND contest_relations.contest_id = submissions_score.contest_id AND submissions_score.score > 0 GROUP BY contest_relations.user_id, contest_relations.contest_id;"
    end
    case ActiveRecord::Base.connection.adapter_name
    when "SQLite"
      execute "CREATE VIEW contests_latest_scoreboard AS SELECT contest_relations.contest_id, contest_relations.user_id, COALESCE(SUM(score),0) AS total_score, STRFTIME('%s',SUBSTR(COALESCE(MAX(submissions_score.created_at),MIN(contest_relations.created_at)),0,27)) - STRFTIME('%s',SUBSTR(MIN(contest_relations.created_at),0,27)) AS time_taken FROM contest_relations LEFT JOIN contests_latest_submissions AS submissions_score ON submissions_score.user_id = contest_relations.user_id AND contest_relations.contest_id = submissions_score.contest_id AND submissions_score.score > 0 GROUP BY contest_relations.user_id, contest_relations.contest_id ORDER BY total_score DESC, time_taken;"
    else
      execute "CREATE VIEW contests_latest_scoreboard AS SELECT contest_relations.contest_id, contest_relations.user_id, COALESCE(SUM(score),0) AS total_score, COALESCE(MAX(submissions_score.created_at),MIN(contest_relations.created_at)) - MIN(contest_relations.created_at) AS time_taken, RANK() OVER (PARTITION BY contest_relations.contest_id ORDER BY COALESCE(SUM(score),0) DESC, COALESCE(MAX(submissions_score.created_at),MIN(contest_relations.created_at)) - MIN(contest_relations.created_at) ASC) AS rank FROM contest_relations LEFT JOIN contests_latest_submissions AS submissions_score ON submissions_score.user_id = contest_relations.user_id AND contest_relations.contest_id = submissions_score.contest_id AND submissions_score.score > 0 GROUP BY contest_relations.user_id, contest_relations.contest_id;"
    end
    execute "CREATE VIEW contests_count_submissions AS SELECT contest_relations.contest_id, submissions.user_id, submissions.problem_id, COUNT(*) AS count FROM contests JOIN contest_relations ON contests.id = contest_relations.contest_id JOIN problem_sets ON contests.problem_set_id = problem_sets.id JOIN problem_sets_problems ON problem_sets_problems.problem_set_id = problem_sets.id JOIN submissions ON contest_relations.user_id = submissions.user_id AND submissions.problem_id = problem_sets_problems.problem_id WHERE submissions.created_at BETWEEN contests.start_time AND contests.end_time GROUP BY contest_relations.contest_id, submissions.user_id, submissions.problem_id;"
  end
end
