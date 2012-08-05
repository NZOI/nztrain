class SendConfirmationInstructionsToAllUsers < ActiveRecord::Migration
  def up
    User.find_each do |user| # for each user without confirmation instructions, send them
      Devise::Mailer.confirmation_instructions(user).deliver if user.confirmation_sent_at.nil?
    end
  end

  def down
  end
end
