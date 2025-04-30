class AddIndexToSleepLogs < ActiveRecord::Migration[8.0]
  def change
    add_index :sleep_logs, [:user_id, :sleep_at, :wake_at]
  end
end
