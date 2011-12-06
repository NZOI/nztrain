# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111206102437) do

  create_table "contest_relations", :force => true do |t|
    t.integer   "user_id"
    t.integer   "contest_id"
    t.timestamp "started_at"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "contests", :force => true do |t|
    t.string    "title"
    t.timestamp "start_time"
    t.timestamp "end_time"
    t.decimal   "duration"
    t.integer   "user_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "contests_groups", :id => false, :force => true do |t|
    t.integer "contest_id"
    t.integer "group_id"
  end

  create_table "contests_problems", :id => false, :force => true do |t|
    t.integer "contest_id"
    t.integer "problem_id"
  end

  create_table "groups", :force => true do |t|
    t.string    "name"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "groups_problems", :id => false, :force => true do |t|
    t.integer "group_id"
    t.integer "problem_id"
  end

  create_table "groups_users", :id => false, :force => true do |t|
    t.integer "group_id"
    t.integer "user_id"
  end

  create_table "problems", :force => true do |t|
    t.string    "title"
    t.text      "statement"
    t.string    "input"
    t.string    "output"
    t.integer   "memory_limit"
    t.decimal   "time_limit"
    t.integer   "user_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "submissions", :force => true do |t|
    t.text      "source"
    t.string    "language"
    t.integer   "score"
    t.integer   "user_id"
    t.integer   "problem_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.text      "judge_output"
  end

  create_table "test_cases", :force => true do |t|
    t.text      "input"
    t.text      "output"
    t.integer   "points"
    t.string    "description"
    t.integer   "problem_id"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string    "email",                                 :default => "",    :null => false
    t.string    "encrypted_password",     :limit => 128, :default => "",    :null => false
    t.string    "reset_password_token"
    t.timestamp "reset_password_sent_at"
    t.timestamp "remember_created_at"
    t.integer   "sign_in_count",                         :default => 0
    t.timestamp "current_sign_in_at"
    t.timestamp "last_sign_in_at"
    t.string    "current_sign_in_ip"
    t.string    "last_sign_in_ip"
    t.boolean   "is_admin",                              :default => false
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "brownie_points",                        :default => 0
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
