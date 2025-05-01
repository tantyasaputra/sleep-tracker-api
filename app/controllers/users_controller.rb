class UsersController < ApplicationController
  def index
    page = ParamHelper.positive_integer(params[:page], 1)
    per_page = ParamHelper.positive_integer(params[:per_page], 10)

    users = User.active.where.not(id: @current_user.id)

    @pagy, @records = pagy(users, limit: per_page, page: page, overflow: :empty_page)

    options = {
      meta: {
        current_page: @pagy.page,
        per_page: @pagy.limit,
        total_pages: @pagy.pages,
        total_count: @pagy.count
      },
      is_collection: true
    }
    render json: UserSerializer.new(@records, options).serializable_hash
  end

  def profiles
    render json: { email: @current_user.email, followers: @current_user.followers.size, following: @current_user.following.size }
  end

  def follow
    other_user = User.active.find(params[:id])
    @current_user.follow!(other_user)

    render json: { code: 201, message: "successfully followed user #{other_user.email}" }, status: :created
  end

  def unfollow
    other_user = User.active.find(params[:id])
    @current_user.unfollow!(other_user)

    render json: { code: 201, message: "successfully unfollowed user #{other_user.email}" }, status: :created
  end
end
