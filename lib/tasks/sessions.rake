namespace :session do
  desc "Delete old sessions from database."
  task :clean => :environment do
   sessions = ActiveRecord::SessionStore::Session.where('updated_at < ? OR created_at < ?', 7.days.ago, 21.days.ago)
   sessions.each {|s| s.delete }
  end
end
