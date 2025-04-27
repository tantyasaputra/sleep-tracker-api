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
    @page = (params[:page] || 1).to_i
    @per_page = (params[:per_page] || 10).to_i

    # Calculate offset
    offset = (@page - 1) * @per_page

    @total_pages = (@total_count.to_f / @per_page).ceil


    previous_days =  params[:duration_days].present? ? params[:duration_days].to_i : 7
    previous_date =  previous_days.days.ago

    following_ids = @current_user.following.pluck(:id)

    time_range = previous_date..Time.current
    @total_count = SleepLog.where(user_id: following_ids)
                           .where(sleep_at: time_range)
                           .where.not(wake_at: nil)
                           .count
    binding.pry

    sleep_logs = SleepLog.where(user_id: following_ids)
                         .where(sleep_at: time_range)
                         .where.not(wake_at: nil)
                         .limit(@per_page)
                         .offset(offset)

    render json: {
      data: sleep_logs.map { |sl| { id: sl.id,
                                    sleep_at: sl.sleep_at,
                                    wake_at: sl.wake_at,
                                    duration: sl.duration,
                                    user_id: sl.user_id,
                                    email: sl.user.email,
      } },
      meta: {
        current_page: @page,
        per_page: @per_page,
        total_pages: @total_pages,
        total_count: @total_count
      }
    }
  end
end
