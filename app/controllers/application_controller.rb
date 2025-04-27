class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include ExceptionHandler

  before_action :authenticate!

  private

  def authenticate!
    authenticate_or_request_with_http_basic do |username, password|
      @current_user = User.find_by(email: username)

      unless @current_user.present?
        raise AuthenticationError, 'invalid user!'
        return false
      end

      unless @current_user.authenticate(password)
        raise AuthenticationError, 'invalid password!'
        return false
      end

      return true
    end
  end
end
