class CreateEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :events do |t|
      t.references :user, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true
      t.string :title
      t.datetime :start_time
      t.datetime :end_time
      t.text :description
      t.string :google_event_id

      t.timestamps
    end
  end
end
