class PostgresqlPhase0Migration < ActiveRecord::Migration[8.0]
  def change
    # Groups テーブル修正: planned_period_start, planned_period_end を追加
    add_column :groups, :planned_period_start, :date unless column_exists?(:groups, :planned_period_start)
    add_column :groups, :planned_period_end, :date unless column_exists?(:groups, :planned_period_end)

    # owner_id カラムが存在する場合は削除（user_id で管理）
    remove_column :groups, :owner_id if column_exists?(:groups, :owner_id)

    # Memberships テーブルにユニークインデックスを追加
    add_index :memberships, [:user_id, :group_id], unique: true, if_not_exists: true

    # Scenarios テーブル修正: user_id と scenario_id を削除、group_id を追加
    remove_column :scenarios, :user_id if column_exists?(:scenarios, :user_id)
    remove_column :scenarios, :scenario_id if column_exists?(:scenarios, :scenario_id)

    # 既にgroup_idが存在しない場合のみ追加
    unless column_exists?(:scenarios, :group_id)
      add_column :scenarios, :group_id, :bigint, null: false
      add_foreign_key :scenarios, :groups unless foreign_key_exists?(:scenarios, :groups)
    end
    add_index :scenarios, :group_id, if_not_exists: true unless index_exists?(:scenarios, :group_id)

    # CalendarEvents テーブル作成（既存 Calendars テーブルの役割を引き継ぐ）
    unless table_exists?(:calendar_events)
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

      # ユニークインデックス
      add_index :calendar_events, [:user_id, :google_event_id], unique: true
      # 検索用インデックス
      add_index :calendar_events, [:user_id, :start_time]
      add_index :calendar_events, [:user_id, :included_in_availability]
    end

    # PendingEvents テーブル作成
    unless table_exists?(:pending_events)
      create_table :pending_events do |t|
        t.references :group, null: false, foreign_key: true, index: { unique: true }
        t.references :scenario, null: false, foreign_key: true
        t.datetime :start_time, null: false
        t.datetime :end_time, null: false

        t.timestamps
      end
    end

    # ConfirmedEvents テーブル作成
    unless table_exists?(:confirmed_events)
      create_table :confirmed_events do |t|
        t.references :group, null: false, foreign_key: true, index: true
        t.references :scenario, null: false, foreign_key: true
        t.string :google_event_id
        t.text :notes
        t.datetime :start_time, null: false
        t.datetime :end_time, null: false

        t.timestamps
      end
    end

    # Approvals テーブル作成
    unless table_exists?(:approvals)
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
end
