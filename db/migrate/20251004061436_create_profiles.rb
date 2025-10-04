class CreateProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :profiles do |t|
      t.references :group, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.integer :holiday_start_time
      t.integer :holiday_end_time
      t.integer :start_time
      t.integer :end_time

      t.timestamps
    end
  end
end
