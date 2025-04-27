class UsersController < ApplicationController

  def index
    @page = (params[:page] || 1).to_i
    @per_page = (params[:per_page] || 10).to_i

    # Calculate offset
    offset = (@page - 1) * @per_page
    @total_count = User.active.where.not(id: @current_user.id).count
    @total_pages = (@total_count.to_f / @per_page).ceil

    @users = User.active
                 .where.not(id: @current_user.id)
                 .select(:id, :email)
                 .order(created_at: :desc)
                 .limit(@per_page)
                 .offset(offset)

    render json: {
      data: @users.map { |user| { id: user.id, email: user.email } },
      meta: {
        current_page: @page,
        per_page: @per_page,
        total_pages: @total_pages,
        total_count: @total_count
      }
    }
  end

  def profiles
    render json: { email: @current_user.email, followers: @current_user.followers.size, following: @current_user.following.size }
  end
end
