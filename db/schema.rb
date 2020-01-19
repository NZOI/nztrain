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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20200119083305) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ai_contest_games", force: true do |t|
    t.integer  "ai_contest_id"
    t.integer  "ai_submission_2_id"
    t.integer  "ai_submission_1_id"
    t.text     "record"
    t.integer  "score_1"
    t.integer  "score_2"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "iteration"
    t.text     "judge_output"
  end

  add_index "ai_contest_games", ["iteration", "ai_submission_1_id", "ai_submission_2_id"], name: "each_game", unique: true, using: :btree

  create_table "ai_contests", force: true do |t|
    t.string   "name"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "owner_id"
    t.datetime "finalized_at"
    t.text     "sample_ai"
    t.text     "statement"
    t.text     "judge"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.integer  "iterations"
    t.integer  "iterations_preview"
  end

  create_table "ai_submissions", force: true do |t|
    t.text     "source"
    t.string   "language"
    t.integer  "user_id"
    t.integer  "ai_contest_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "name"
    t.boolean  "active",        default: false
  end

  create_table "contest_relations", force: true do |t|
    t.integer  "user_id"
    t.integer  "contest_id"
    t.datetime "started_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "finish_at"
    t.integer  "score",                   default: 0,     null: false
    t.float    "time_taken",              default: 0.0,   null: false
    t.integer  "school_id"
    t.integer  "status",                  default: 0
    t.integer  "extra_time",              default: 0
    t.datetime "start_time"
    t.datetime "end_time"
    t.string   "country_code",  limit: 2
    t.integer  "school_year"
    t.integer  "supervisor_id"
    t.boolean  "checked_in",              default: false
  end

  add_index "contest_relations", ["contest_id", "score", "time_taken"], name: "index_contest_relations_on_contest_id_and_score_and_time_taken", order: {"score"=>:desc}, using: :btree
  add_index "contest_relations", ["contest_id", "user_id"], name: "index_contest_relations_on_contest_id_and_user_id", unique: true, using: :btree
  add_index "contest_relations", ["user_id", "started_at"], name: "index_contest_relations_on_user_id_and_started_at", using: :btree

  create_table "contest_scores", force: true do |t|
    t.integer  "contest_relation_id", null: false
    t.integer  "problem_id",          null: false
    t.integer  "score"
    t.integer  "attempts"
    t.integer  "attempt"
    t.integer  "submission_id"
    t.datetime "updated_at"
  end

  add_index "contest_scores", ["contest_relation_id", "problem_id"], name: "index_contest_scores_on_contest_relation_id_and_problem_id", using: :btree

  create_table "contest_supervisors", force: true do |t|
    t.integer  "contest_id"
    t.integer  "user_id"
    t.string   "site_type"
    t.integer  "site_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "scheduled_start_time"
  end

  create_table "contests", force: true do |t|
    t.string   "name"
    t.datetime "start_time"
    t.datetime "end_time"
    t.decimal  "duration"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "problem_set_id"
    t.datetime "finalized_at"
    t.string   "startcode"
    t.integer  "observation",    default: 1
    t.integer  "registration",   default: 0
    t.integer  "affiliation",    default: 0
  end

  create_table "entities", force: true do |t|
    t.string  "name"
    t.integer "entity_id"
    t.string  "entity_type"
  end

  create_table "evaluators", force: true do |t|
    t.string   "name",                     null: false
    t.text     "description", default: "", null: false
    t.text     "source",      default: "", null: false
    t.integer  "owner_id",                 null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "file_attachments", force: true do |t|
    t.string   "name"
    t.string   "file_attachment"
    t.integer  "owner_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "filelinks", force: true do |t|
    t.integer  "root_id"
    t.integer  "file_attachment_id"
    t.datetime "created_at"
    t.string   "filepath"
    t.string   "root_type"
    t.integer  "visibility",         limit: 2, default: 0
  end

  add_index "filelinks", ["file_attachment_id"], name: "index_filelinks_on_file_attachment_id", using: :btree
  add_index "filelinks", ["root_id", "filepath"], name: "index_filelinks_on_root_id_and_filepath", using: :btree

  create_table "forem_categories", force: true do |t|
    t.string   "name",                   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.integer  "position",   default: 0
  end

  add_index "forem_categories", ["slug"], name: "index_forem_categories_on_slug", unique: true, using: :btree

  create_table "forem_forums", force: true do |t|
    t.string  "name"
    t.text    "description"
    t.integer "category_id"
    t.integer "views_count", default: 0
    t.string  "slug"
    t.integer "position",    default: 0
  end

  add_index "forem_forums", ["slug"], name: "index_forem_forums_on_slug", unique: true, using: :btree

  create_table "forem_groups", force: true do |t|
    t.string "name"
  end

  add_index "forem_groups", ["name"], name: "index_forem_groups_on_name", using: :btree

  create_table "forem_memberships", force: true do |t|
    t.integer "group_id"
    t.integer "member_id"
  end

  add_index "forem_memberships", ["group_id"], name: "index_forem_memberships_on_group_id", using: :btree

  create_table "forem_moderator_groups", force: true do |t|
    t.integer "forum_id"
    t.integer "group_id"
  end

  add_index "forem_moderator_groups", ["forum_id"], name: "index_forem_moderator_groups_on_forum_id", using: :btree

  create_table "forem_posts", force: true do |t|
    t.integer  "topic_id"
    t.text     "text"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reply_to_id"
    t.string   "state",       default: "pending_review"
    t.boolean  "notified",    default: false
  end

  add_index "forem_posts", ["reply_to_id"], name: "index_forem_posts_on_reply_to_id", using: :btree
  add_index "forem_posts", ["state"], name: "index_forem_posts_on_state", using: :btree
  add_index "forem_posts", ["topic_id"], name: "index_forem_posts_on_topic_id", using: :btree
  add_index "forem_posts", ["user_id"], name: "index_forem_posts_on_user_id", using: :btree

  create_table "forem_subscriptions", force: true do |t|
    t.integer "subscriber_id"
    t.integer "topic_id"
  end

  create_table "forem_topics", force: true do |t|
    t.integer  "forum_id"
    t.integer  "user_id"
    t.string   "subject"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "locked",       default: false,            null: false
    t.boolean  "pinned",       default: false
    t.boolean  "hidden",       default: false
    t.datetime "last_post_at"
    t.string   "state",        default: "pending_review"
    t.integer  "views_count",  default: 0
    t.string   "slug"
  end

  add_index "forem_topics", ["forum_id"], name: "index_forem_topics_on_forum_id", using: :btree
  add_index "forem_topics", ["slug"], name: "index_forem_topics_on_slug", unique: true, using: :btree
  add_index "forem_topics", ["state"], name: "index_forem_topics_on_state", using: :btree
  add_index "forem_topics", ["user_id"], name: "index_forem_topics_on_user_id", using: :btree

  create_table "forem_views", force: true do |t|
    t.integer  "user_id"
    t.integer  "viewable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "count",             default: 0
    t.string   "viewable_type"
    t.datetime "current_viewed_at"
    t.datetime "past_viewed_at"
  end

  add_index "forem_views", ["updated_at"], name: "index_forem_views_on_updated_at", using: :btree
  add_index "forem_views", ["user_id"], name: "index_forem_views_on_user_id", using: :btree
  add_index "forem_views", ["viewable_id"], name: "index_forem_views_on_viewable_id", using: :btree

  create_table "group_contests", force: true do |t|
    t.integer "group_id"
    t.integer "contest_id"
  end

  add_index "group_contests", ["contest_id", "group_id"], name: "index_group_contests_on_contest_id_and_group_id", using: :btree
  add_index "group_contests", ["group_id", "contest_id"], name: "index_group_contests_on_group_id_and_contest_id", using: :btree

  create_table "group_memberships", force: true do |t|
    t.integer  "group_id"
    t.integer  "member_id"
    t.datetime "created_at"
  end

  create_table "group_problem_sets", force: true do |t|
    t.integer "group_id"
    t.integer "problem_set_id"
    t.string  "name"
  end

  add_index "group_problem_sets", ["group_id", "problem_set_id"], name: "index_group_problem_sets_on_group_id_and_problem_set_id", using: :btree
  add_index "group_problem_sets", ["problem_set_id", "group_id"], name: "index_group_problem_sets_on_problem_set_id_and_group_id", using: :btree

  create_table "groups", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.integer  "visibility", default: 0, null: false
    t.integer  "membership", default: 0, null: false
  end

  create_table "item_histories", force: true do |t|
    t.integer  "item_id"
    t.boolean  "active"
    t.integer  "action"
    t.integer  "holder_id"
    t.string   "data"
    t.datetime "acted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", force: true do |t|
    t.integer "product_id"
    t.integer "owner_id"
    t.integer "organisation_id"
    t.integer "sponsor_id"
    t.integer "condition"
    t.integer "status"
    t.integer "holder_id"
    t.integer "donator_id"
    t.integer "scan_token"
  end

  create_table "language_groups", force: true do |t|
    t.string   "identifier"
    t.string   "name"
    t.integer  "current_language_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "language_groups", ["identifier"], name: "index_language_groups_on_identifier", unique: true, using: :btree

  create_table "languages", force: true do |t|
    t.string   "identifier"
    t.string   "compiler"
    t.boolean  "interpreted"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "extension"
    t.boolean  "compiled"
    t.string   "name"
    t.string   "lexer"
    t.integer  "group_id"
    t.string   "source_filename"
    t.string   "exe_extension"
    t.string   "compiler_command"
    t.string   "interpreter"
    t.string   "interpreter_command"
    t.integer  "processes",           default: 1
  end

  add_index "languages", ["identifier"], name: "index_languages_on_identifier", unique: true, using: :btree

  create_table "organisations", force: true do |t|
  end

  create_table "problem_series", force: true do |t|
    t.string "name"
    t.string "identifier"
    t.string "importer_type"
    t.text   "index_yaml"
  end

  create_table "problem_set_problems", force: true do |t|
    t.integer "problem_set_id"
    t.integer "problem_id"
    t.integer "problem_set_order"
    t.integer "weighting",         default: 100
  end

  add_index "problem_set_problems", ["problem_id", "problem_set_id"], name: "index_problem_set_problems_on_problem_id_and_problem_set_id", using: :btree
  add_index "problem_set_problems", ["problem_set_id", "problem_id"], name: "index_problem_set_problems_on_problem_set_id_and_problem_id", using: :btree

  create_table "problem_sets", force: true do |t|
    t.string   "name"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "finalized_contests_count", default: 0
  end

  create_table "problems", force: true do |t|
    t.string   "name"
    t.text     "statement"
    t.string   "input"
    t.string   "output"
    t.integer  "memory_limit"
    t.decimal  "time_limit"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "evaluator_id"
    t.datetime "rejudge_at"
    t.integer  "test_error_count",   default: 0
    t.integer  "test_warning_count", default: 0
    t.integer  "test_status",        default: 0
  end

  create_table "products", force: true do |t|
    t.string  "name"
    t.integer "gtin",        limit: 8
    t.text    "description"
    t.string  "image"
  end

  create_table "requests", force: true do |t|
    t.integer  "requester_id"
    t.integer  "subject_id"
    t.string   "subject_type"
    t.string   "verb",                            null: false
    t.integer  "target_id",                       null: false
    t.string   "target_type",                     null: false
    t.integer  "status",       default: 0,        null: false
    t.integer  "requestee_id"
    t.datetime "expired_at",   default: Infinity, null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "roles", force: true do |t|
    t.string "name"
  end

  create_table "roles_users", id: false, force: true do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "schools", force: true do |t|
    t.string  "name"
    t.string  "country_code", limit: 2
    t.integer "users_count"
    t.integer "synonym_id"
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["created_at"], name: "index_sessions_on_created_at", using: :btree
  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "settings", force: true do |t|
    t.string "key"
    t.string "value"
  end

  add_index "settings", ["key"], name: "index_settings_on_key", unique: true, using: :btree

  create_table "submissions", force: true do |t|
    t.text     "source"
    t.integer  "score"
    t.integer  "user_id"
    t.integer  "problem_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "input"
    t.string   "output"
    t.integer  "language_id"
    t.text     "judge_log"
    t.datetime "judged_at"
    t.string   "job"
    t.integer  "classification"
    t.string   "test_errors",    array: true
    t.string   "test_warnings",  array: true
    t.float    "evaluation"
    t.decimal  "points"
    t.integer  "maximum_points"
  end

  add_index "submissions", ["problem_id", "created_at"], name: "index_submissions_on_problem_id_and_created_at", using: :btree
  add_index "submissions", ["user_id", "problem_id"], name: "index_submissions_on_user_id_and_problem_id", using: :btree

  create_table "test_case_relations", force: true do |t|
    t.integer  "test_case_id"
    t.integer  "test_set_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "test_case_relations", ["test_case_id"], name: "index_test_case_relations_on_test_case_id", using: :btree
  add_index "test_case_relations", ["test_set_id"], name: "index_test_case_relations_on_test_set_id", using: :btree

  create_table "test_cases", force: true do |t|
    t.text     "input"
    t.text     "output"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "problem_id"
    t.boolean  "sample",        default: false
    t.integer  "problem_order"
  end

  add_index "test_cases", ["problem_id", "name"], name: "index_test_cases_on_problem_id_and_name", unique: true, using: :btree

  create_table "test_sets", force: true do |t|
    t.integer  "problem_id"
    t.integer  "points"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "prerequisite",  default: false
    t.integer  "problem_order"
  end

  add_index "test_sets", ["problem_id", "name"], name: "index_test_sets_on_problem_id_and_name", unique: true, using: :btree

  create_table "user_problem_relations", force: true do |t|
    t.integer  "problem_id"
    t.integer  "user_id"
    t.integer  "submissions_count"
    t.integer  "ranked_score"
    t.integer  "ranked_submission_id"
    t.integer  "submission_id"
    t.datetime "last_viewed_at"
    t.datetime "first_viewed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_problem_relations", ["problem_id", "ranked_score"], name: "index_user_problem_relations_on_problem_id_and_ranked_score", using: :btree
  add_index "user_problem_relations", ["user_id", "problem_id"], name: "index_user_problem_relations_on_user_id_and_problem_id", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                              default: "",               null: false
    t.string   "encrypted_password",     limit: 128, default: "",               null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "brownie_points",                     default: 0
    t.string   "name"
    t.string   "username",                                                      null: false
    t.boolean  "can_change_username",                default: false,            null: false
    t.string   "avatar"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "last_seen_at"
    t.integer  "school_id"
    t.string   "country_code",           limit: 3
    t.date     "school_graduation"
    t.boolean  "forem_admin",                        default: false
    t.string   "forem_state",                        default: "pending_review"
    t.boolean  "forem_auto_subscribe",               default: false
    t.integer  "default_language_id"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
