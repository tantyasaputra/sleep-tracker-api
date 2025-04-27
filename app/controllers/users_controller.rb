class UsersController < ApplicationController
  def profiles
    render json: { email: @current_user.email, followers: @current_user.followers.size, following: @current_user.following.size }
  end
end
