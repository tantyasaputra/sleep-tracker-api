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
end
