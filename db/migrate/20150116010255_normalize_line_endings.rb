class NormalizeLineEndings < ActiveRecord::Migration[4.2]
  def change
    TestCase.where("(input LIKE '%\r%') OR (output LIKE '%\r%')").find_each do |tc|
      tc.input = tc.input
      tc.output = tc.output
      tc.save
    end

    # for pre-execution, because above code takes forever in a single transaction
    # (0...1).each { TestCase.where("(input LIKE '%\r%') OR (output LIKE '%\r%')").limit(10).each do |tc| tc.input = tc.input; tc.output = tc.output; tc.save; end; sleep(1); }
  end
end
