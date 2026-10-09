class CreateSteps < ActiveRecord::Migration[8.1]
  def change
    create_table :steps do |t|
      t.references :quest, null: false, foreign_key: true
      t.string :description, null: false
      t.boolean :done, null: false, default: false
      t.integer :position, null: false

      t.timestamps
    end
  end
end
