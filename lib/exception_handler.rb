module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from HandledErrors::AuthenticationError do |e|
      render json: { error: e.message }, status: 401
    end

    rescue_from HandledErrors::InvalidParamsError do |e|
      render json: { error: e.message }, status: 422
    end
  end
end
