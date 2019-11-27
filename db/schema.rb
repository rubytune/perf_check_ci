# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_11_27_153137) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "jobs", force: :cascade do |t|
    t.string "status"
    t.string "log_filename"
    t.datetime "queued_at"
    t.datetime "run_at"
    t.datetime "completed_at"
    t.datetime "failed_at"
    t.datetime "canceled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "experiment_branch"
    t.text "result_details"
    t.integer "user_id"
    t.string "github_html_url"
    t.text "output"
    t.text "reference_branch", default: "master"
    t.string "task", default: "compare_branches"
    t.integer "number_of_requests", default: 20
    t.json "request_headers"
    t.json "request_paths"
    t.boolean "use_fragment_cache", default: true
    t.boolean "run_migrations", default: true
    t.boolean "diff_response", default: true
    t.string "request_user_role"
    t.text "request_user_email"
    t.json "measurements"
    t.index ["user_id"], name: "index_jobs_on_user_id"
  end

  create_table "perf_check_job_test_cases", force: :cascade do |t|
    t.bigint "job_id"
    t.string "status"
    t.string "http_status"
    t.decimal "max_memory"
    t.decimal "branch_latency"
    t.decimal "reference_latency"
    t.integer "branch_query_count"
    t.integer "reference_query_count"
    t.decimal "latency_difference"
    t.decimal "speedup_factor"
    t.string "diff_file_path"
    t.text "error_backtrace"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "resource_benchmarked"
    t.index ["job_id"], name: "index_perf_check_job_test_cases_on_job_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "github_login"
    t.string "github_avatar_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["github_login"], name: "index_users_on_github_login", unique: true
  end

end
