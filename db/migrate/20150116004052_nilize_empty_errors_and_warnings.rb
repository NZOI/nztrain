class NilizeEmptyErrorsAndWarnings < ActiveRecord::Migration
  def up
    Submission.where.not(test_errors: nil, test_warnings: nil).find_each do |s|
      s.test_errors = nil if s.test_errors.nil? || s.test_errors.empty?
      s.test_warnings = nil if s.test_warnings.nil? || s.test_warnings.empty?
      s.save
    end
  end

  def down
  end
end
