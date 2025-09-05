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

ActiveRecord::Schema.define(version: 20250903000840) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "contest_relations", force: :cascade do |t|
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
    t.index ["contest_id", "score", "time_taken"], name: "index_contest_relations_on_contest_id_and_score_and_time_taken", order: { score: :desc }, using: :btree
    t.index ["contest_id", "user_id"], name: "index_contest_relations_on_contest_id_and_user_id", unique: true, using: :btree
    t.index ["user_id", "started_at"], name: "index_contest_relations_on_user_id_and_started_at", using: :btree
  end

  create_table "contest_scores", force: :cascade do |t|
    t.integer  "contest_relation_id", null: false
    t.integer  "problem_id",          null: false
    t.integer  "score"
    t.integer  "attempts"
    t.integer  "attempt"
    t.integer  "submission_id"
    t.datetime "updated_at"
    t.index ["contest_relation_id", "problem_id"], name: "index_contest_scores_on_contest_relation_id_and_problem_id", using: :btree
  end

  create_table "contest_supervisors", force: :cascade do |t|
    t.integer  "contest_id"
    t.integer  "user_id"
    t.string   "site_type",            limit: 255
    t.integer  "site_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "scheduled_start_time"
  end

  create_table "contests", force: :cascade do |t|
    t.string   "name",                           limit: 255
    t.datetime "start_time"
    t.datetime "end_time"
    t.decimal  "duration"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "problem_set_id"
    t.datetime "finalized_at"
    t.string   "startcode",                      limit: 255
    t.integer  "observation",                                default: 1
    t.integer  "registration",                               default: 0
    t.integer  "affiliation",                                default: 0
    t.boolean  "live_scoreboard",                            default: true
    t.boolean  "only_rank_official_contestants",             default: false
  end

  create_table "entities", force: :cascade do |t|
    t.string  "name",        limit: 255
    t.integer "entity_id"
    t.string  "entity_type", limit: 255
  end

  create_table "evaluators", force: :cascade do |t|
    t.string   "name",        limit: 255,              null: false
    t.text     "description",             default: "", null: false
    t.text     "source",                  default: "", null: false
    t.integer  "owner_id",                             null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "language_id"
  end

  create_table "file_attachments", force: :cascade do |t|
    t.string   "name",            limit: 255
    t.string   "file_attachment", limit: 255
    t.integer  "owner_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "filelinks", force: :cascade do |t|
    t.integer  "root_id"
    t.integer  "file_attachment_id"
    t.datetime "created_at"
    t.string   "filepath",           limit: 255
    t.string   "root_type",          limit: 255
    t.integer  "visibility",         limit: 2,   default: 0
    t.index ["file_attachment_id"], name: "index_filelinks_on_file_attachment_id", using: :btree
    t.index ["root_id", "filepath"], name: "index_filelinks_on_root_id_and_filepath", using: :btree
  end

  create_table "group_contests", force: :cascade do |t|
    t.integer "group_id"
    t.integer "contest_id"
    t.index ["contest_id", "group_id"], name: "index_group_contests_on_contest_id_and_group_id", using: :btree
    t.index ["group_id", "contest_id"], name: "index_group_contests_on_group_id_and_contest_id", using: :btree
  end

  create_table "group_memberships", force: :cascade do |t|
    t.integer  "group_id"
    t.integer  "member_id"
    t.datetime "created_at"
  end

  create_table "group_problem_sets", force: :cascade do |t|
    t.integer "group_id"
    t.integer "problem_set_id"
    t.string  "name",           limit: 255
    t.index ["group_id", "problem_set_id"], name: "index_group_problem_sets_on_group_id_and_problem_set_id", using: :btree
    t.index ["problem_set_id", "group_id"], name: "index_group_problem_sets_on_problem_set_id_and_group_id", using: :btree
  end

  create_table "groups", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.integer  "visibility",             default: 0, null: false
    t.integer  "membership",             default: 0, null: false
  end

  create_table "item_histories", force: :cascade do |t|
    t.integer  "item_id"
    t.boolean  "active"
    t.integer  "action"
    t.integer  "holder_id"
    t.string   "data",       limit: 255
    t.datetime "acted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", force: :cascade do |t|
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

  create_table "language_groups", force: :cascade do |t|
    t.string   "identifier",          limit: 255
    t.string   "name",                limit: 255
    t.integer  "current_language_id"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.index ["identifier"], name: "index_language_groups_on_identifier", unique: true, using: :btree
  end

  create_table "languages", force: :cascade do |t|
    t.string   "identifier",          limit: 255
    t.string   "compiler",            limit: 255
    t.boolean  "interpreted"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.string   "extension",           limit: 255
    t.boolean  "compiled"
    t.string   "name",                limit: 255
    t.string   "lexer",               limit: 255
    t.integer  "group_id"
    t.string   "source_filename",     limit: 255
    t.string   "exe_extension",       limit: 255
    t.string   "compiler_command",    limit: 255
    t.string   "interpreter",         limit: 255
    t.string   "interpreter_command", limit: 255
    t.integer  "processes",                       default: 1
    t.index ["identifier"], name: "index_languages_on_identifier", unique: true, using: :btree
  end

  create_table "organisations", force: :cascade do |t|
  end

  create_table "problem_series", force: :cascade do |t|
    t.string "name",          limit: 255
    t.string "identifier",    limit: 255
    t.string "importer_type", limit: 255
    t.text   "index_yaml"
  end

  create_table "problem_set_problems", force: :cascade do |t|
    t.integer "problem_set_id"
    t.integer "problem_id"
    t.integer "problem_set_order"
    t.integer "weighting",         default: 100
    t.index ["problem_id", "problem_set_id"], name: "index_problem_set_problems_on_problem_id_and_problem_set_id", using: :btree
    t.index ["problem_set_id", "problem_id"], name: "index_problem_set_problems_on_problem_set_id_and_problem_id", using: :btree
  end

  create_table "problem_sets", force: :cascade do |t|
    t.string   "name",                     limit: 255
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "finalized_contests_count",             default: 0
  end

  create_table "problems", force: :cascade do |t|
    t.string   "name",               limit: 255
    t.text     "statement"
    t.string   "input",              limit: 255
    t.string   "output",             limit: 255
    t.integer  "memory_limit"
    t.decimal  "time_limit"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "evaluator_id"
    t.datetime "rejudge_at"
    t.integer  "test_error_count",               default: 0
    t.integer  "test_warning_count",             default: 0
    t.integer  "test_status",                    default: 0
    t.integer  "scoring_method",                 default: 1
  end

  create_table "products", force: :cascade do |t|
    t.string "name",        limit: 255
    t.bigint "gtin"
    t.text   "description"
    t.string "image",       limit: 255
  end

  create_table "requests", force: :cascade do |t|
    t.integer  "requester_id"
    t.integer  "subject_id"
    t.string   "subject_type", limit: 255
    t.string   "verb",         limit: 255,                      null: false
    t.integer  "target_id",                                     null: false
    t.string   "target_type",  limit: 255,                      null: false
    t.integer  "status",                   default: 0,          null: false
    t.integer  "requestee_id"
    t.datetime "expired_at",               default: 'Infinity', null: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "roles_users", id: false, force: :cascade do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "schools", force: :cascade do |t|
    t.string  "name",         limit: 255
    t.string  "country_code", limit: 2
    t.integer "users_count"
    t.integer "synonym_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", limit: 255, null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["created_at"], name: "index_sessions_on_created_at", using: :btree
    t.index ["session_id"], name: "index_sessions_on_session_id", using: :btree
    t.index ["updated_at"], name: "index_sessions_on_updated_at", using: :btree
  end

  create_table "settings", force: :cascade do |t|
    t.string "key",   limit: 255
    t.string "value", limit: 255
    t.index ["key"], name: "index_settings_on_key", unique: true, using: :btree
  end

  create_table "submissions", force: :cascade do |t|
    t.text     "source"
    t.integer  "score"
    t.integer  "user_id"
    t.integer  "problem_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "input",          limit: 255
    t.string   "output",         limit: 255
    t.integer  "language_id"
    t.text     "judge_log"
    t.datetime "judged_at"
    t.string   "job",            limit: 255
    t.integer  "classification"
    t.string   "test_errors",    limit: 255, array: true
    t.string   "test_warnings",  limit: 255, array: true
    t.float    "evaluation"
    t.decimal  "points"
    t.integer  "maximum_points"
    t.index ["problem_id", "created_at"], name: "index_submissions_on_problem_id_and_created_at", using: :btree
    t.index ["user_id", "problem_id"], name: "index_submissions_on_user_id_and_problem_id", using: :btree
  end

  create_table "test_case_relations", force: :cascade do |t|
    t.integer  "test_case_id"
    t.integer  "test_set_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["test_case_id"], name: "index_test_case_relations_on_test_case_id", using: :btree
    t.index ["test_set_id"], name: "index_test_case_relations_on_test_set_id", using: :btree
  end

  create_table "test_cases", force: :cascade do |t|
    t.text     "input"
    t.text     "output"
    t.string   "name",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "problem_id"
    t.boolean  "sample",                    default: false
    t.integer  "problem_order"
    t.index ["problem_id", "name"], name: "index_test_cases_on_problem_id_and_name", unique: true, using: :btree
  end

  create_table "test_sets", force: :cascade do |t|
    t.integer  "problem_id"
    t.integer  "points"
    t.string   "name",          limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "prerequisite",              default: false
    t.integer  "problem_order"
    t.index ["problem_id", "name"], name: "index_test_sets_on_problem_id_and_name", unique: true, using: :btree
  end

  create_table "user_problem_relations", force: :cascade do |t|
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
    t.decimal  "unweighted_score"
    t.index ["problem_id", "ranked_score"], name: "index_user_problem_relations_on_problem_id_and_ranked_score", using: :btree
    t.index ["user_id", "problem_id"], name: "index_user_problem_relations_on_user_id_and_problem_id", unique: true, using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "brownie_points",                     default: 0
    t.string   "name",                   limit: 255
    t.string   "username",               limit: 255,                 null: false
    t.boolean  "can_change_username",                default: false, null: false
    t.string   "avatar",                 limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.datetime "last_seen_at"
    t.integer  "school_id"
    t.string   "country_code",           limit: 3
    t.date     "school_graduation"
    t.index "lower((username)::text)", name: "index_users_on_username", unique: true, using: :btree
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

end
