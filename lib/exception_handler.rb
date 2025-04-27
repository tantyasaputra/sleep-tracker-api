module ExceptionHandler
  extend ActiveSupport::Concern

  included do
    rescue_from AuthenticationError do |e|
      render json: { error: e.message }, status: 401
    end

    rescue_from InvalidParamsError do |e|
      render json: { error: e.message }, status: 422
    end
  end
end

class AuthenticationError < StandardError; end
class InvalidParamsError < StandardError; end
