class CreateSleepLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :sleep_logs do |t|
      t.timestamps
    end
  end
end
