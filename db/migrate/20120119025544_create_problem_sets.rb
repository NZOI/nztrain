class CreateProblemSets < ActiveRecord::Migration
  def self.up
    create_table :problem_sets do |t|
      t.string :title
      t.integer :user_id
      t.timestamps null: true
    end
    # add association tables
    create_table :problem_sets_problems, id: false do |t|
      t.integer :problem_set_id
      t.integer :problem_id
    end
    create_table :groups_problem_sets, id: false do |t|
      t.integer :group_id
      t.integer :problem_set_id
    end
    add_column :contests, :problem_set_id, :integer

    # create a problem set for each contest
    execute "INSERT INTO problem_sets (\"title\",\"user_id\",\"created_at\",\"updated_at\") SELECT title, user_id, created_at, updated_at FROM contests;"
    # move contests_problems into problem_sets_problems
    execute "INSERT INTO problem_sets_problems (\"problem_set_id\",\"problem_id\") SELECT problem_sets.id, problem_id FROM contests_problems JOIN contests ON contests.id = contests_problems.contest_id JOIN problem_sets ON problem_sets.title = contests.title AND contests.created_at = problem_sets.created_at AND contests.updated_at = problem_sets.updated_at AND problem_sets.user_id = contests.user_id;"
    # reference problem set from each contest
    execute "UPDATE contests SET problem_set_id = (SELECT problem_sets.id FROM problem_sets WHERE problem_sets.title = contests.title AND contests.created_at = problem_sets.created_at AND contests.updated_at = problem_sets.updated_at AND problem_sets.user_id = contests.user_id);"

    # create a problem set for every group
    execute "INSERT INTO problem_sets (\"title\",\"user_id\",\"created_at\",\"updated_at\") SELECT name, 0 AS user_id, created_at, updated_at FROM groups;"
    # put groups_problems into problem_sets_problems
    execute "INSERT INTO problem_sets_problems (\"problem_set_id\",\"problem_id\") SELECT problem_sets.id, groups_problems.problem_id FROM groups_problems JOIN groups ON groups.id = groups_problems.group_id JOIN problem_sets ON problem_sets.title = groups.name AND problem_sets.created_at = groups.created_at AND problem_sets.updated_at = groups.updated_at;"
    # reference problem set for each group
    execute "INSERT INTO groups_problem_sets (\"group_id\",\"problem_set_id\") SELECT groups.id, problem_sets.id FROM groups JOIN problem_sets ON problem_sets.title = groups.name AND groups.created_at = problem_sets.created_at AND groups.updated_at = problem_sets.updated_at;"


    # rewrite views to go through problem_sets table for problems
    execute "DROP VIEW contests_max_score_scoreboard"
    execute "DROP VIEW contests_latest_scoreboard"

    execute "DROP VIEW contests_max_score_submissions"
    case ActiveRecord::Base.connection.adapter_name
    when 'SQLite'
      execute "CREATE VIEW contests_max_score_submissions AS SELECT submissions.id, submissions.score as score, submissions.user_id, submissions.problem_id, submissions.created_at, submissions.updated_at, contest_relations.contest_id FROM contests JOIN contest_relations ON contests.id = contest_relations.contest_id JOIN problem_sets ON contests.problem_set_id = problem_sets.id JOIN problem_sets_problems ON problem_sets_problems.problem_set_id = problem_sets.id JOIN submissions ON contest_relations.user_id = submissions.user_id AND submissions.problem_id = problem_sets_problems.problem_id WHERE submissions.created_at BETWEEN contests.start_time AND contests.end_time GROUP BY contests.id, submissions.user_id, submissions.problem_id ORDER BY contests.id, submissions.user_id, submissions.problem_id, score DESC, submissions.created_at ASC;"
    else
      execute "CREATE VIEW contests_max_score_submissions AS SELECT DISTINCT ON (contests.id, submissions.user_id, submissions.problem_id) submissions.id, submissions.score as score, submissions.user_id, submissions.problem_id, submissions.created_at, submissions.updated_at, contest_relations.contest_id FROM contests JOIN contest_relations ON contests.id = contest_relations.contest_id JOIN problem_sets ON contests.problem_set_id = problem_sets.id JOIN problem_sets_problems ON problem_sets_problems.problem_set_id = problem_sets.id JOIN submissions ON contest_relations.user_id = submissions.user_id AND submissions.problem_id = problem_sets_problems.problem_id WHERE submissions.created_at BETWEEN contests.start_time AND contests.end_time ORDER BY contests.id, submissions.user_id, submissions.problem_id, score DESC, submissions.created_at ASC;"
    end

    execute "DROP VIEW contests_latest_submissions"
    case ActiveRecord::Base.connection.adapter_name
    when 'SQLite'
      execute "CREATE VIEW contests_latest_submissions AS SELECT submissions.id, submissions.score as score, submissions.user_id, submissions.problem_id, submissions.created_at, submissions.updated_at, contest_relations.contest_id FROM contests JOIN contest_relations ON contests.id = contest_relations.contest_id JOIN problem_sets ON contests.problem_set_id = problem_sets.id JOIN problem_sets_problems ON problem_sets_problems.problem_set_id = problem_sets.id JOIN submissions ON contest_relations.user_id = submissions.user_id AND submissions.problem_id = problem_sets_problems.problem_id WHERE submissions.created_at BETWEEN contests.start_time AND contests.end_time GROUP BY contests.id, submissions.user_id, submissions.problem_id ORDER BY contests.id, submissions.user_id, submissions.problem_id, submissions.created_at DESC;"
    else
      execute "CREATE VIEW contests_latest_submissions AS SELECT DISTINCT ON (contests.id, submissions.user_id, submissions.problem_id) submissions.id, submissions.score as score, submissions.user_id, submissions.problem_id, submissions.created_at, submissions.updated_at, contest_relations.contest_id FROM contests JOIN contest_relations ON contests.id = contest_relations.contest_id JOIN problem_sets ON contests.problem_set_id = problem_sets.id JOIN problem_sets_problems ON problem_sets_problems.problem_set_id = problem_sets.id JOIN submissions ON contest_relations.user_id = submissions.user_id AND submissions.problem_id = problem_sets_problems.problem_id WHERE submissions.created_at BETWEEN contests.start_time AND contests.end_time ORDER BY contests.id, submissions.user_id, submissions.problem_id, submissions.created_at DESC;"
    end

    execute "DROP VIEW contests_count_submissions"
    execute "CREATE VIEW contests_count_submissions AS SELECT contest_relations.contest_id, submissions.user_id, submissions.problem_id, COUNT(*) AS count FROM contests JOIN contest_relations ON contests.id = contest_relations.contest_id JOIN problem_sets ON contests.problem_set_id = problem_sets.id JOIN problem_sets_problems ON problem_sets_problems.problem_set_id = problem_sets.id JOIN submissions ON contest_relations.user_id = submissions.user_id AND submissions.problem_id = problem_sets_problems.problem_id WHERE submissions.created_at BETWEEN contests.start_time AND contests.end_time GROUP BY contest_relations.contest_id, submissions.user_id, submissions.problem_id;"

    # 2 views not changed, however, they rely on views that change
    case ActiveRecord::Base.connection.adapter_name
    when 'SQLite'
      execute "CREATE VIEW contests_max_score_scoreboard AS SELECT contest_relations.contest_id, contest_relations.user_id, COALESCE(SUM(score),0) AS total_score, STRFTIME('%s',SUBSTR(COALESCE(MAX(submissions_score.created_at),MIN(contest_relations.created_at)),0,27)) - STRFTIME('%s',SUBSTR(MIN(contest_relations.created_at),0,27)) AS time_taken FROM contest_relations LEFT JOIN contests_max_score_submissions AS submissions_score ON submissions_score.user_id = contest_relations.user_id AND contest_relations.contest_id = submissions_score.contest_id AND submissions_score.score > 0 GROUP BY contest_relations.user_id, contest_relations.contest_id ORDER BY total_score DESC, time_taken;"
    else
      execute "CREATE VIEW contests_max_score_scoreboard AS SELECT contest_relations.contest_id, contest_relations.user_id, COALESCE(SUM(score),0) AS total_score, COALESCE(MAX(submissions_score.created_at),MIN(contest_relations.created_at)) - MIN(contest_relations.created_at) AS time_taken, RANK() OVER (PARTITION BY contest_relations.contest_id ORDER BY COALESCE(SUM(score),0) DESC, COALESCE(MAX(submissions_score.created_at),MIN(contest_relations.created_at)) - MIN(contest_relations.created_at) ASC) AS rank FROM contest_relations LEFT JOIN contests_max_score_submissions AS submissions_score ON submissions_score.user_id = contest_relations.user_id AND contest_relations.contest_id = submissions_score.contest_id AND submissions_score.score > 0 GROUP BY contest_relations.user_id, contest_relations.contest_id;"
    end
    case ActiveRecord::Base.connection.adapter_name
    when 'SQLite'
      execute "CREATE VIEW contests_latest_scoreboard AS SELECT contest_relations.contest_id, contest_relations.user_id, COALESCE(SUM(score),0) AS total_score, STRFTIME('%s',SUBSTR(COALESCE(MAX(submissions_score.created_at),MIN(contest_relations.created_at)),0,27)) - STRFTIME('%s',SUBSTR(MIN(contest_relations.created_at),0,27)) AS time_taken FROM contest_relations LEFT JOIN contests_latest_submissions AS submissions_score ON submissions_score.user_id = contest_relations.user_id AND contest_relations.contest_id = submissions_score.contest_id AND submissions_score.score > 0 GROUP BY contest_relations.user_id, contest_relations.contest_id ORDER BY total_score DESC, time_taken;"
    else
      execute "CREATE VIEW contests_latest_scoreboard AS SELECT contest_relations.contest_id, contest_relations.user_id, COALESCE(SUM(score),0) AS total_score, COALESCE(MAX(submissions_score.created_at),MIN(contest_relations.created_at)) - MIN(contest_relations.created_at) AS time_taken, RANK() OVER (PARTITION BY contest_relations.contest_id ORDER BY COALESCE(SUM(score),0) DESC, COALESCE(MAX(submissions_score.created_at),MIN(contest_relations.created_at)) - MIN(contest_relations.created_at) ASC) AS rank FROM contest_relations LEFT JOIN contests_latest_submissions AS submissions_score ON submissions_score.user_id = contest_relations.user_id AND contest_relations.contest_id = submissions_score.contest_id AND submissions_score.score > 0 GROUP BY contest_relations.user_id, contest_relations.contest_id;"
    end
  end

  def self.down
    execute "DROP VIEW contests_max_score_scoreboard"
    execute "DROP VIEW contests_latest_scoreboard"

    execute "DROP VIEW contests_count_submissions"
    execute "CREATE VIEW contests_count_submissions AS SELECT contest_relations.contest_id, submissions.user_id, submissions.problem_id, COUNT(*) AS count FROM contests JOIN contest_relations ON contests.id = contest_relations.contest_id JOIN contests_problems ON contests_problems.contest_id = contests.id JOIN submissions ON contest_relations.user_id = submissions.user_id AND submissions.problem_id = contests_problems.problem_id WHERE submissions.created_at BETWEEN contests.start_time AND contests.end_time GROUP BY contest_relations.contest_id, submissions.user_id, submissions.problem_id;"

    execute "DROP VIEW contests_latest_submissions"
    case ActiveRecord::Base.connection.adapter_name
    when 'SQLite'
      execute "CREATE VIEW contests_latest_submissions AS SELECT submissions.id, submissions.score as score, submissions.user_id, submissions.problem_id, submissions.created_at, submissions.updated_at, contest_relations.contest_id FROM contests JOIN contest_relations ON contests.id = contest_relations.contest_id JOIN contests_problems ON contests_problems.contest_id = contests.id JOIN submissions ON contest_relations.user_id = submissions.user_id AND submissions.problem_id = contests_problems.problem_id WHERE submissions.created_at BETWEEN contests.start_time AND contests.end_time GROUP BY contests.id, submissions.user_id, submissions.problem_id ORDER BY contests.id, submissions.user_id, submissions.problem_id, submissions.created_at DESC;"
    else
      execute "CREATE VIEW contests_latest_submissions AS SELECT DISTINCT ON (contests.id, submissions.user_id, submissions.problem_id) submissions.id, submissions.score as score, submissions.user_id, submissions.problem_id, submissions.created_at, submissions.updated_at, contest_relations.contest_id FROM contests JOIN contest_relations ON contests.id = contest_relations.contest_id JOIN contests_problems ON contests_problems.contest_id = contests.id JOIN submissions ON contest_relations.user_id = submissions.user_id AND submissions.problem_id = contests_problems.problem_id WHERE submissions.created_at BETWEEN contests.start_time AND contests.end_time ORDER BY contests.id, submissions.user_id, submissions.problem_id, submissions.created_at DESC;"
    end

    execute "DROP VIEW contests_max_score_submissions"
    case ActiveRecord::Base.connection.adapter_name
    when 'SQLite'
      execute "CREATE VIEW contests_max_score_submissions AS SELECT submissions.id, submissions.score as score, submissions.user_id, submissions.problem_id, submissions.created_at, submissions.updated_at, contest_relations.contest_id FROM contests JOIN contest_relations ON contests.id = contest_relations.contest_id JOIN contests_problems ON contests_problems.contest_id = contests.id JOIN submissions ON contest_relations.user_id = submissions.user_id AND submissions.problem_id = contests_problems.problem_id WHERE submissions.created_at BETWEEN contests.start_time AND contests.end_time GROUP BY contests.id, submissions.user_id, submissions.problem_id ORDER BY contests.id, submissions.user_id, submissions.problem_id, score DESC, submissions.created_at ASC;"
    else
      execute "CREATE VIEW contests_max_score_submissions AS SELECT DISTINCT ON (contests.id, submissions.user_id, submissions.problem_id) submissions.id, submissions.score as score, submissions.user_id, submissions.problem_id, submissions.created_at, submissions.updated_at, contest_relations.contest_id FROM contests JOIN contest_relations ON contests.id = contest_relations.contest_id JOIN contests_problems ON contests_problems.contest_id = contests.id JOIN submissions ON contest_relations.user_id = submissions.user_id AND submissions.problem_id = contests_problems.problem_id WHERE submissions.created_at BETWEEN contests.start_time AND contests.end_time ORDER BY contests.id, submissions.user_id, submissions.problem_id, score DESC, submissions.created_at ASC;"
    end

    # 2 views not changed, however, they rely on views that change
    case ActiveRecord::Base.connection.adapter_name
    when 'SQLite'
      execute "CREATE VIEW contests_max_score_scoreboard AS SELECT contest_relations.contest_id, contest_relations.user_id, COALESCE(SUM(score),0) AS total_score, STRFTIME('%s',SUBSTR(COALESCE(MAX(submissions_score.created_at),MIN(contest_relations.created_at)),0,27)) - STRFTIME('%s',SUBSTR(MIN(contest_relations.created_at),0,27)) AS time_taken FROM contest_relations LEFT JOIN contests_max_score_submissions AS submissions_score ON submissions_score.user_id = contest_relations.user_id AND contest_relations.contest_id = submissions_score.contest_id AND submissions_score.score > 0 GROUP BY contest_relations.user_id, contest_relations.contest_id ORDER BY total_score DESC, time_taken;"
    else
      execute "CREATE VIEW contests_max_score_scoreboard AS SELECT contest_relations.contest_id, contest_relations.user_id, COALESCE(SUM(score),0) AS total_score, COALESCE(MAX(submissions_score.created_at),MIN(contest_relations.created_at)) - MIN(contest_relations.created_at) AS time_taken, RANK() OVER (PARTITION BY contest_relations.contest_id ORDER BY COALESCE(SUM(score),0) DESC, COALESCE(MAX(submissions_score.created_at),MIN(contest_relations.created_at)) - MIN(contest_relations.created_at) ASC) AS rank FROM contest_relations LEFT JOIN contests_max_score_submissions AS submissions_score ON submissions_score.user_id = contest_relations.user_id AND contest_relations.contest_id = submissions_score.contest_id AND submissions_score.score > 0 GROUP BY contest_relations.user_id, contest_relations.contest_id;"
    end
    case ActiveRecord::Base.connection.adapter_name
    when 'SQLite'
      execute "CREATE VIEW contests_latest_scoreboard AS SELECT contest_relations.contest_id, contest_relations.user_id, COALESCE(SUM(score),0) AS total_score, STRFTIME('%s',SUBSTR(COALESCE(MAX(submissions_score.created_at),MIN(contest_relations.created_at)),0,27)) - STRFTIME('%s',SUBSTR(MIN(contest_relations.created_at),0,27)) AS time_taken FROM contest_relations LEFT JOIN contests_latest_submissions AS submissions_score ON submissions_score.user_id = contest_relations.user_id AND contest_relations.contest_id = submissions_score.contest_id AND submissions_score.score > 0 GROUP BY contest_relations.user_id, contest_relations.contest_id ORDER BY total_score DESC, time_taken;"
    else
      execute "CREATE VIEW contests_latest_scoreboard AS SELECT contest_relations.contest_id, contest_relations.user_id, COALESCE(SUM(score),0) AS total_score, COALESCE(MAX(submissions_score.created_at),MIN(contest_relations.created_at)) - MIN(contest_relations.created_at) AS time_taken, RANK() OVER (PARTITION BY contest_relations.contest_id ORDER BY COALESCE(SUM(score),0) DESC, COALESCE(MAX(submissions_score.created_at),MIN(contest_relations.created_at)) - MIN(contest_relations.created_at) ASC) AS rank FROM contest_relations LEFT JOIN contests_latest_submissions AS submissions_score ON submissions_score.user_id = contest_relations.user_id AND contest_relations.contest_id = submissions_score.contest_id AND submissions_score.score > 0 GROUP BY contest_relations.user_id, contest_relations.contest_id;"
    end

    remove_column :contests, :problem_set_id

    drop_table :groups_problem_sets
    drop_table :problem_sets_problems
    drop_table :problem_sets
  end
end
