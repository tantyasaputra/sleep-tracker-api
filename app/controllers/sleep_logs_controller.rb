class SleepLogsController < ApplicationController
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
    page = params[:page].to_i
    page = 1 if page <= 0

    per_page = params[:per_page].to_i
    per_page = 10 if per_page <= 0

    duration_days = params[:duration_days].to_i
    duration_days = 7 if duration_days <= 0

    offset = (page - 1) * per_page
    previous_date = duration_days.days.ago
    time_range = previous_date..Time.current

    following_ids = @current_user.following.pluck(:id)

    sleep_logs_query = SleepLog.where(user_id: following_ids)
                               .where(sleep_at: time_range)
                               .where.not(wake_at: nil)

    total_count = sleep_logs_query.count
    total_pages = (total_count.to_f / per_page).ceil

    sleep_logs = sleep_logs_query
                   .order(duration: :desc) # optional: add ordering if needed
                   .limit(per_page)
                   .offset(offset)

    render json: {
      data: sleep_logs.map do |sleep_log|
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
        current_page: page,
        per_page: per_page,
        total_pages: total_pages,
        total_count: total_count
      }
    }
  end
end