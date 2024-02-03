class AddLanguageIdToSubmission < ActiveRecord::Migration
  def up
    add_column :submissions, :language_id, :integer
    rename_column :submissions, :language, :old_language

    Submission.select(:old_language).uniq.each do |submission|
      Language.where(:name => submission.old_language).first_or_create!
    end

    execute "UPDATE submissions SET language_id = (SELECT id FROM languages WHERE languages.name = submissions.old_language);"
    # Check that language relations migrated successfully
    failures = Submission.where(:language_id => nil).count
    raise "Languages in #{failures} submissions failed to migrate" if failures > 0

    remove_column :submissions, :old_language
  end

  def down
    add_column :submissions, :old_language, :string

    execute "UPDATE submissions SET old_language = (SELECT name FROM languages WHERE languages.id = submissions.language_id);"

    rename_column :submissions, :old_language, :language
    remove_column :submissions, :language_id
  end
end
