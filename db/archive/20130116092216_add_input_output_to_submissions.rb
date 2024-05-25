class AddInputOutputToSubmissions < ActiveRecord::Migration
  def up
    add_column :submissions, :input, :string
    add_column :submissions, :output, :string

    Submission.all.each do |sub|
      sub.input = sub.problem.input
      sub.output = sub.problem.output
      sub.save
    end
  end

  def down
    remove_column :submissions, :input
    remove_column :submissions, :output
  end
end
