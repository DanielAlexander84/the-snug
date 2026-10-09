class CreateQuests < ActiveRecord::Migration[8.1]
  def change
    create_table :quests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :room, null: false, foreign_key: true
      t.string :title, null: false

      t.timestamps
    end
  end
end
