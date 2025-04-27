class UsersController < ApplicationController
  def profiles
    render json: { email: @current_user.email }
  end
end
