class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include ExceptionHandler

  before_action :authenticate

  private

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      @current_user = User.find_by(email: username)

      raise AuthenticationError, 'invalid user!' unless @current_user.present?
      raise AuthenticationError, 'invalid password!' unless @current_user.authenticate(password)
    end
  end
end
