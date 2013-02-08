# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20130116092216) do

  create_table "ai_contest_games", :force => true do |t|
    t.integer  "ai_contest_id"
    t.integer  "ai_submission_2_id"
    t.integer  "ai_submission_1_id"
    t.text     "record"
    t.integer  "score_1"
    t.integer  "score_2"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "iteration"
    t.text     "judge_output"
  end

  add_index "ai_contest_games", ["iteration", "ai_submission_1_id", "ai_submission_2_id"], :name => "each_game", :unique => true

  create_table "ai_contests", :force => true do |t|
    t.string   "title"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "owner_id"
    t.datetime "finalized_at"
    t.text     "sample_ai"
    t.text     "statement"
    t.text     "judge"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "iterations"
    t.integer  "iterations_preview"
  end

  create_table "ai_submissions", :force => true do |t|
    t.text     "source"
    t.string   "language"
    t.integer  "user_id"
    t.integer  "ai_contest_id"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.string   "name"
    t.boolean  "active",        :default => false
  end

  create_table "contest_relations", :force => true do |t|
    t.integer  "user_id"
    t.integer  "contest_id"
    t.datetime "started_at"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.datetime "finish_at"
    t.integer  "score",      :default => 0,   :null => false
    t.float    "time_taken", :default => 0.0, :null => false
  end

  add_index "contest_relations", ["contest_id", "score", "time_taken"], :name => "index_contest_relations_on_contest_id_and_score_and_time_taken", :order => {"score"=>:desc}
  add_index "contest_relations", ["contest_id", "user_id"], :name => "index_contest_relations_on_contest_id_and_user_id", :unique => true
  add_index "contest_relations", ["user_id", "started_at"], :name => "index_contest_relations_on_user_id_and_started_at"

  create_table "contest_scores", :force => true do |t|
    t.integer  "contest_relation_id", :null => false
    t.integer  "problem_id",          :null => false
    t.integer  "score"
    t.integer  "attempts"
    t.integer  "attempt"
    t.integer  "submission_id"
    t.datetime "updated_at"
  end

  add_index "contest_scores", ["contest_relation_id", "problem_id"], :name => "index_contest_scores_on_contest_relation_id_and_problem_id"

  create_table "contests", :force => true do |t|
    t.string   "title"
    t.datetime "start_time"
    t.datetime "end_time"
    t.decimal  "duration"
    t.integer  "owner_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "problem_set_id"
    t.datetime "finalized_at"
  end

  create_table "contests_groups", :id => false, :force => true do |t|
    t.integer "contest_id"
    t.integer "group_id"
  end

  create_table "evaluators", :force => true do |t|
    t.string   "name",                        :null => false
    t.text     "description", :default => "", :null => false
    t.text     "source",      :default => "", :null => false
    t.integer  "owner_id",                    :null => false
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "owner_id"
  end

  create_table "groups_problem_sets", :id => false, :force => true do |t|
    t.integer "group_id"
    t.integer "problem_set_id"
  end

  create_table "groups_users", :id => false, :force => true do |t|
    t.integer "group_id"
    t.integer "user_id"
  end

  add_index "groups_users", ["group_id"], :name => "index_groups_users_on_group_id"
  add_index "groups_users", ["user_id"], :name => "index_groups_users_on_user_id"

  create_table "problem_sets", :force => true do |t|
    t.string   "title"
    t.integer  "owner_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "problem_sets_problems", :id => false, :force => true do |t|
    t.integer "problem_set_id"
    t.integer "problem_id"
  end

  create_table "problems", :force => true do |t|
    t.string   "title"
    t.text     "statement"
    t.string   "input"
    t.string   "output"
    t.integer  "memory_limit"
    t.decimal  "time_limit"
    t.integer  "owner_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "evaluator_id"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "roles_users", :id => false, :force => true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["created_at"], :name => "index_sessions_on_created_at"
  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "settings", :force => true do |t|
    t.string "key"
    t.string "value"
  end

  add_index "settings", ["key"], :name => "index_settings_on_key", :unique => true

  create_table "submissions", :force => true do |t|
    t.text     "source"
    t.string   "language"
    t.integer  "score"
    t.integer  "user_id"
    t.integer  "problem_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.text     "judge_output"
    t.text     "debug_output"
    t.string   "input"
    t.string   "output"
  end

  add_index "submissions", ["problem_id", "created_at"], :name => "index_submissions_on_problem_id_and_created_at"
  add_index "submissions", ["user_id", "problem_id"], :name => "index_submissions_on_user_id_and_problem_id"

  create_table "test_cases", :force => true do |t|
    t.text     "input"
    t.text     "output"
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "test_set_id"
  end

  create_table "test_sets", :force => true do |t|
    t.integer  "problem_id"
    t.integer  "points"
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
    t.integer  "brownie_points",         :default => 0
    t.string   "name"
    t.string   "username",                                  :null => false
    t.boolean  "can_change_username",    :default => false, :null => false
    t.string   "avatar"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
