class CreateUserScenarios < ActiveRecord::Migration[8.0]
  def change
    create_table :user_scenarios do |t|
      t.references :user, null: false, foreign_key: true
      t.references :scenario, null: false, foreign_key: true
      t.string :status
      t.text :notes

      t.timestamps
    end
  end
end
