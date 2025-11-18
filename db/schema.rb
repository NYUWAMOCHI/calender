# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_11_18_000001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "approvals", force: :cascade do |t|
    t.bigint "pending_event_id", null: false
    t.bigint "user_id", null: false
    t.boolean "approved", default: false
    t.datetime "approved_at"
    t.boolean "auto_created", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pending_event_id", "user_id"], name: "index_approvals_on_pending_event_id_and_user_id", unique: true
    t.index ["pending_event_id"], name: "index_approvals_on_pending_event_id"
    t.index ["user_id"], name: "index_approvals_on_user_id"
  end

  create_table "availabilities", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.string "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_availabilities_on_user_id"
  end

  create_table "calendar_events", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "google_calendar_id"
    t.string "google_event_id"
    t.string "title", null: false
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.text "description"
    t.boolean "included_in_availability", default: true
    t.datetime "synced_at"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "google_event_id"], name: "index_calendar_events_on_user_id_and_google_event_id", unique: true
    t.index ["user_id", "included_in_availability"], name: "index_calendar_events_on_user_id_and_included_in_availability"
    t.index ["user_id", "start_time"], name: "index_calendar_events_on_user_id_and_start_time"
    t.index ["user_id"], name: "index_calendar_events_on_user_id"
  end

  create_table "calendars", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "google_calendar_id"
    t.string "google_event_id"
    t.string "name"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_calendars_on_user_id"
  end

  create_table "confirmed_events", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.bigint "scenario_id", null: false
    t.string "google_event_id"
    t.text "notes"
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_confirmed_events_on_group_id"
    t.index ["scenario_id"], name: "index_confirmed_events_on_scenario_id"
  end

  create_table "events", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "group_id", null: false
    t.string "title"
    t.datetime "start_time"
    t.datetime "end_time"
    t.text "description"
    t.string "google_event_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_events_on_group_id"
    t.index ["user_id"], name: "index_events_on_user_id"
  end

  create_table "groups", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.text "intro"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "planned_period_start"
    t.date "planned_period_end"
    t.index ["user_id"], name: "index_groups_on_user_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "group_id", null: false
    t.integer "role"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_memberships_on_group_id"
    t.index ["user_id", "group_id"], name: "index_memberships_on_user_id_and_group_id", unique: true
    t.index ["user_id"], name: "index_memberships_on_user_id"
  end

  create_table "pending_events", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.bigint "scenario_id", null: false
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_pending_events_on_group_id", unique: true
    t.index ["scenario_id"], name: "index_pending_events_on_scenario_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.bigint "group_id", null: false
    t.bigint "user_id", null: false
    t.string "title"
    t.text "description"
    t.integer "holiday_start_time"
    t.integer "holiday_end_time"
    t.integer "weekday_start_time"
    t.integer "weekday_end_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_profiles_on_group_id"
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "scenarios", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "group_id", null: false
    t.index ["group_id"], name: "index_scenarios_on_group_id"
  end

  create_table "user_scenarios", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "scenario_id", null: false
    t.string "status"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["scenario_id"], name: "index_user_scenarios_on_scenario_id"
    t.index ["user_id"], name: "index_user_scenarios_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", default: "", null: false
    t.string "google_uid"
    t.string "google_access_token"
    t.string "google_refresh_token"
    t.datetime "google_token_expires_at"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["google_uid"], name: "index_users_on_google_uid", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "approvals", "pending_events"
  add_foreign_key "approvals", "users"
  add_foreign_key "availabilities", "users"
  add_foreign_key "calendar_events", "users"
  add_foreign_key "calendars", "users"
  add_foreign_key "confirmed_events", "groups"
  add_foreign_key "confirmed_events", "scenarios"
  add_foreign_key "events", "groups"
  add_foreign_key "events", "users"
  add_foreign_key "groups", "users"
  add_foreign_key "memberships", "groups"
  add_foreign_key "memberships", "users"
  add_foreign_key "pending_events", "groups"
  add_foreign_key "pending_events", "scenarios"
  add_foreign_key "profiles", "groups"
  add_foreign_key "profiles", "users"
  add_foreign_key "scenarios", "groups"
  add_foreign_key "user_scenarios", "scenarios"
  add_foreign_key "user_scenarios", "users"
end
