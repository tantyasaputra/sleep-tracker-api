class UsersController < ApplicationController
  def index
    page = params[:page].present? ? params[:page].to_i : 1
    per_page = params[:per_page].present? ? params[:per_page] : 10

    # Calculate offset
    offset = (page - 1) * per_page

    users_query = User.active.where.not(id: @current_user.id)

    total_count = users_query.count
    total_pages = total_count.zero? ? 0 : (total_count.to_f / per_page).ceil

    users = users_query
              .select(:id, :email)
              .order(created_at: :desc)
              .limit(per_page)
              .offset(offset)

    render json: {
      data: users.as_json(only: [ :id, :email ]),
      meta: {
        current_page: page,
        per_page: per_page,
        total_pages: total_pages,
        total_count: total_count
      }
    }
  end

  def profiles
    render json: { email: @current_user.email, followers: @current_user.followers.size, following: @current_user.following.size }
  end

  def follow
    other_user = User.active.find(params[:id])
    @current_user.follow!(other_user)

    render json: { code: 200, message: "successfully followed user #{other_user.email}" }
  end

  def unfollow
    other_user = User.active.find(params[:id])
    @current_user.unfollow!(other_user)

    render json: { code: 200, message: "successfully unfollowed user #{other_user.email}" }
  end
end
