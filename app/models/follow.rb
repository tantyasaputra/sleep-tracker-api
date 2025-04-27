class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  validates :follower_id, presence: true
  validates :followed_id, presence: true
  validates :follower_id, uniqueness: { scope: :followed_id }

  # Scope to only active (not deleted) follows
  scope :active, -> { where(deleted_at: nil) }

  # Soft delete instead of destroy
  def soft_delete
    update(deleted_at: Time.current)
  end

  # Check if this follow is soft deleted
  def deleted?
    deleted_at.present?
  end
end
