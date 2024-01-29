class AddLanguageIdToEvaluators < ActiveRecord::Migration
  def change
    add_column :evaluators, :language_id, :integer
  end
end
