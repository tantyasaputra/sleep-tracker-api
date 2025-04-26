class User < ApplicationRecord
  validates :email, presence: true, uniqueness: true

  def destroy
    update(deleted_at: Time.current)
  end
  def deleted?
    deleted_at.present?
  end

  # Scope for only active users
  scope :active, -> { where(deleted_at: nil) }
end
