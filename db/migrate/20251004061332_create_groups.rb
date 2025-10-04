class CreateGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :groups do |t|
      t.references :user, null: false, foreign_key: true
      t.string :owner_id
      t.string :name
      t.text :intro

      t.timestamps
    end
  end
end
