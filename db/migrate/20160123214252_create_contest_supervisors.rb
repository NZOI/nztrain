class CreateContestSupervisors < ActiveRecord::Migration
  def change
    create_table :contest_supervisors do |t|
      t.integer :contest_id
      t.integer :user_id
      t.string :site_type
      t.integer :site_id

      t.timestamps null: true
    end
  end
end
