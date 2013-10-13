class AddLanguageIdToSubmission < ActiveRecord::Migration
  def change
    add_column :submissions, :language_id, :integer
  end
end
