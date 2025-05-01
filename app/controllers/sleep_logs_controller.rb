class SleepLogsController < ApplicationController
  def index
    page = ParamHelper.positive_integer(params[:page], 1)
    per_page = ParamHelper.positive_integer(params[:per_page], 10)
    past_days = ParamHelper.positive_integer(params[:past_days], 7)
    time_range = past_days.days.ago..Time.current

    sleep_logs = SleepLog.includes([ :user ])
                         .where(user_id: @current_user.id)
                         .where(sleep_at: time_range)
                         .order(sorting_param)

    @pagy, @records = pagy(sleep_logs, limit: per_page, page: page, overflow: :empty_page)

    options = {
      meta: {
        current_page: @pagy.page,
        per_page: @pagy.limit,
        total_pages: @pagy.pages,
        total_count: @pagy.count
      },
      is_collection: true
    }
    render json: SleepLogSerializer.new(@records, options).serializable_hash
  end

  def clock_in
    sleep_log = SleepLog.clock_in(@current_user)
    render json: { code: 201, message: "successfully clocked in", sleep_log: sleep_log }, status: :created
  rescue HandledErrors::InvalidParamsError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def clock_out
    SleepLog.clock_out(@current_user)
    render json: { code: 201, message: "successfully clocked out" }, status: :created
  rescue HandledErrors::InvalidParamsError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  def following
    page = ParamHelper.positive_integer(params[:page], 1)
    per_page = ParamHelper.positive_integer(params[:per_page], 10)
    past_days = ParamHelper.positive_integer(params[:past_days], 7)

    time_range = past_days.days.ago..Time.current

    following_ids = @current_user.following.pluck(:id)
    sleep_logs = SleepLog.includes([ :user ])
                         .where(user_id: following_ids)
                         .where(sleep_at: time_range)
                         .where.not(wake_at: nil)
                         .order(sorting_param)

    @pagy, @records = pagy(sleep_logs, limit: per_page, page: page, overflow: :empty_page)

    options = {
      meta: {
        current_page: @pagy.page,
        per_page: @pagy.limit,
        total_pages: @pagy.pages,
        total_count: @pagy.count
      },
      is_collection: true
    }
    render json: SleepLogSerializer.new(@records, options).serializable_hash
  end

  private
  def sorting_param
    sort_param = params[:sort].presence || "-sleep_at"
    column = sort_param.sub("-", "")
    direction = sort_param.start_with?("-") ? :desc : :asc

    # Prevent SQL injection
    SleepLog.column_names.include?(column) ? { column => direction } : { sleep_at: :desc }
  end
end
