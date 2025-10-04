class CreateScenarios < ActiveRecord::Migration[8.0]
  def change
    create_table :scenarios do |t|
      t.references :user, null: false, foreign_key: true
      t.string :scenario_id

      t.timestamps
    end
  end
end
