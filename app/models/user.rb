class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, length: { minimum: 6 }, on: :create

  has_many :active_follows, -> { active }, class_name: "Follow", foreign_key: "follower_id", dependent: :destroy
  has_many :following, through: :active_follows, source: :followed

  has_many :passive_follows, -> { active }, class_name: "Follow", foreign_key: "followed_id", dependent: :destroy
  has_many :followers, through: :passive_follows, source: :follower

  # Scope for only active users
  scope :active, -> { where(deleted_at: nil) }

  def destroy
    soft_delete_follows
    update(deleted_at: Time.current)
  end
  def deleted?
    deleted_at.present?
  end

  def follow!(other_user)
    raise HandledErrors::InvalidParamsError, "cannot follow yourself!" if self == other_user
    raise HandledErrors::InvalidParamsError, "you have followed this person!" if following?(other_user)

    follow = Follow.find_by(follower_id: id, followed_id: other_user.id)

    if follow&.deleted?
      # If there was a soft-deleted follow, restore it
      follow.update(deleted_at: nil)
    else
      # Otherwise create a new follow
      following << other_user
    end
  end

  # Unfollow another user
  def unfollow!(other_user)
    follow = active_follows.find_by(followed_id: other_user.id)
    raise HandledErrors::InvalidParamsError, "you are not following this person!" unless following?(other_user)

    follow.soft_delete if follow
  end

  # Is following this user?
  def following?(other_user)
    following.include?(other_user)
  end

  # Soft delete the follows where the user is a follower or followed
  def soft_delete_follows
    active_follows.update_all(deleted_at: Time.current)
    passive_follows.update_all(deleted_at: Time.current)
  end
end
