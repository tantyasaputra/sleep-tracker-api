class SleepLog < ApplicationRecord
  belongs_to :user

  # Callback to update the duration whenever sleep_time or wake_time changes
  before_save :calculate_duration

  def self.clock_in(user)
    raise HandledErrors::InvalidParamsError, 'you are already clocked in!' if user.sleep_logs.where(wake_at: nil).exists?

    user.sleep_logs.create(sleep_at: Time.current)
  end

  def self.clock_out(user)
    sleep_log = user.sleep_logs.where(wake_at: nil)
    raise HandledErrors::InvalidParamsError, 'you have not clocked in!' unless sleep_log.exists?

    sleep_log.update(wake_at: Time.current)
  end

  private

  def calculate_duration
    if sleep_at.present? && wake_at.present?
      self.duration = wake_at - sleep_at
    end
  end
end