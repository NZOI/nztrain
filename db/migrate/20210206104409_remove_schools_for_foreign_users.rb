class RemoveSchoolsForForeignUsers < ActiveRecord::Migration
  def up
    User.find_each do |user|
      if user.country_code != "NZ" && user.school
        user.school = nil
        user.save!
      end
    end
  end

  def down
  end
end
