class CreateSleepLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :sleep_logs do |t|
      t.references :user, foreign_key: true
      t.datetime :sleep_at, null: false
      t.datetime :wake_at
      t.integer :duration

      t.timestamps
    end
  end
end
