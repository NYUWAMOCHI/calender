# frozen_string_literal: true

class InitializeDatabaseForPostgresql < ActiveRecord::Migration[8.0]
  def change
    # ==========================================
    # Users テーブル（Devise）
    # ==========================================
    create_table :users do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string :name,               null: false, default: ""

      ## Google OAuth2
      t.string :google_uid
      t.string :google_access_token
      t.string :google_refresh_token
      t.datetime :google_token_expires_at

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :google_uid,           unique: true

    # ==========================================
    # Groups テーブル（卓）
    # ==========================================
    create_table :groups do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.string :name, null: false
      t.text :intro
      t.date :planned_period_start, null: false
      t.date :planned_period_end, null: false

      t.timestamps
    end

    # ==========================================
    # Memberships テーブル（グループメンバーシップ）
    # ==========================================
    create_table :memberships do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.references :group, null: false, foreign_key: true, index: true
      t.integer :role, null: false
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :memberships, [:user_id, :group_id], unique: true

    # ==========================================
    # Scenarios テーブル（シナリオ）
    # ==========================================
    create_table :scenarios do |t|
      t.references :group, null: false, foreign_key: true, index: true
      t.string :name, null: false

      t.timestamps
    end

    # ==========================================
    # Events テーブル（従来のイベント）
    # ==========================================
    create_table :events do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.references :group, null: false, foreign_key: true, index: true
      t.string :title
      t.datetime :start_time
      t.datetime :end_time
      t.text :description
      t.string :google_event_id

      t.timestamps
    end

    # ==========================================
    # Calendars テーブル（従来のカレンダー）
    # ==========================================
    create_table :calendars do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.string :google_calendar_id
      t.string :google_event_id
      t.string :name
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end

    # ==========================================
    # CalendarEvents テーブル（Google Calendar 同期）
    # ==========================================
    create_table :calendar_events do |t|
      t.references :user, null: false, foreign_key: true, index: true

      # Google Calendar からの同期情報
      t.string :google_calendar_id
      t.string :google_event_id

      # イベント情報
      t.string :title, null: false
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.text :description

      # 可用性・管理情報
      t.boolean :included_in_availability, default: true
      t.datetime :synced_at
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :calendar_events, [:user_id, :google_event_id], unique: true
    add_index :calendar_events, [:user_id, :start_time]
    add_index :calendar_events, [:user_id, :included_in_availability]

    # ==========================================
    # Profiles テーブル（ユーザープロフィール）
    # ==========================================
    create_table :profiles do |t|
      t.references :group, null: false, foreign_key: true, index: true
      t.references :user, null: false, foreign_key: true, index: true
      t.string :title
      t.text :description
      t.integer :holiday_start_time
      t.integer :holiday_end_time
      t.integer :weekday_start_time
      t.integer :weekday_end_time

      t.timestamps
    end

    add_index :profiles, [:group_id, :user_id], unique: true

    # ==========================================
    # Availabilities テーブル（可用性）
    # ==========================================
    create_table :availabilities do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.datetime :start_time
      t.datetime :end_time
      t.string :source

      t.timestamps
    end

    # ==========================================
    # UserScenarios テーブル（ユーザーシナリオ）
    # ==========================================
    create_table :user_scenarios do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.references :scenario, null: false, foreign_key: true, index: true
      t.string :status
      t.text :notes

      t.timestamps
    end

    add_index :user_scenarios, [:user_id, :scenario_id], unique: true

    # ==========================================
    # PendingEvents テーブル（候補日程）
    # ==========================================
    create_table :pending_events do |t|
      t.references :group, null: false, foreign_key: true, index: { unique: true }
      t.references :scenario, null: false, foreign_key: true, index: true
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false

      t.timestamps
    end

    # ==========================================
    # ConfirmedEvents テーブル（確定済み日程）
    # ==========================================
    create_table :confirmed_events do |t|
      t.references :group, null: false, foreign_key: true, index: true
      t.references :scenario, null: false, foreign_key: true, index: true
      t.string :google_event_id
      t.text :notes
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false

      t.timestamps
    end

    # ==========================================
    # Approvals テーブル（承認管理）
    # ==========================================
    create_table :approvals do |t|
      t.references :pending_event, null: false, foreign_key: true, index: true
      t.references :user, null: false, foreign_key: true, index: true
      t.boolean :approved, default: false
      t.datetime :approved_at
      t.boolean :auto_created, default: false

      t.timestamps
    end

    add_index :approvals, [:pending_event_id, :user_id], unique: true
  end
end
