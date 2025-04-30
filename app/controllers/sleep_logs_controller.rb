class SleepLogsController < ApplicationController
  include Pagy::Backend
  include Pagy::Frontend
  def clock_in
    sleep_log = SleepLog.clock_in(@current_user)
    render json: { message: "successfully clocked in", sleep_log: sleep_log }, status: :created
  rescue HandledErrors::InvalidParamsError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def clock_out
    SleepLog.clock_out(@current_user)
    render json: { message: "successfully clocked out" }, status: :ok
  rescue HandledErrors::InvalidParamsError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def following
    per_page = params[:per_page].to_i
    per_page = 10 if per_page <= 0

    duration_days = params[:duration_days].to_i
    duration_days = 7 if duration_days <= 0

    time_range = duration_days.days.ago..Time.current

    following_ids = @current_user.following.pluck(:id)
    sleep_logs = SleepLog.where(user_id: following_ids)
                               .where(sleep_at: time_range)
                               .where.not(wake_at: nil)

    @pagy, @records = pagy(sleep_logs, limit: per_page, overflow: :empty_page)

    render json: {
      data: @records.map do |sleep_log|
        {
          id: sleep_log.id,
          sleep_at: sleep_log.sleep_at,
          wake_at: sleep_log.wake_at,
          duration: sleep_log.duration,
          user_id: sleep_log.user_id,
          email: sleep_log.user.email
        }
      end,
      meta: {
        current_page: @pagy.page,
        per_page: @pagy.limit,
        total_pages: @pagy.pages,
        total_count: @pagy.count
      }
    }
  end
end
