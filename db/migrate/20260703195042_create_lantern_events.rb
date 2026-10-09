class CreateLanternEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :lantern_events do |t|
      t.references :quest, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      # Immutable, append-only: one row per lantern lighting. Never updated,
      # never decremented — the count of rows for a quest *is* the history.
      t.datetime :created_at, null: false
    end
  end
end
