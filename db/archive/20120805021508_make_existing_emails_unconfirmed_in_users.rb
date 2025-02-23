class MakeExistingEmailsUnconfirmedInUsers < ActiveRecord::Migration
  def up
    User.find_each do |user|
      if user[:unconfirmed_email].nil?
        user[:unconfirmed_email] = user[:email]
        user[:name] = user[:username] if user[:name].empty?
        user.save
      end
    end
  end

  def down
    User.find_each do |user|
      if user[:unconfirmed_email] == user[:email]
        user[:unconfirmed_email] = nil
        user.save
      end
    end
  end
end
