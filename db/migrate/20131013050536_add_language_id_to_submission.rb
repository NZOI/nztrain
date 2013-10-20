class AddLanguageIdToSubmission < ActiveRecord::Migration
  def up
    add_column :submissions, :language_id, :integer
    add_column :submissions, :old_language, :string
    Submission.update_all 'old_language=language'
    Submission.find_each do |submission|
      submission.language = Language.find_by_name(submission.old_language)
      submission.save
    end
  end

  def down
    remove_column :submissions, :language_id
    remove_column :submissions, :old_language
  end
end
