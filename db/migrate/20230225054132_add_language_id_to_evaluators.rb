class AddLanguageIdToEvaluators < ActiveRecord::Migration[4.2]
  def change
    add_column :evaluators, :language_id, :integer
  end
end
