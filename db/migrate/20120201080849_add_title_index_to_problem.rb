class AddTitleIndexToProblem < ActiveRecord::Migration[4.2]
  def self.up
    case ActiveRecord::Base.connection.adapter_name
    when "SQLite"
      execute "CREATE INDEX index_problems_on_title ON problems (title collate nocase)"
    else
      execute "CREATE UNIQUE INDEX index_problems_on_title ON problems (lower(title))"
    end
  end

  def self.down
    execute "DROP INDEX index_problems_on_title"
  end
end
