
class GroupMember < ApplicationRecord
  enum :role, { member: 0, admin: 1 }
  belongs_to :group
  belongs_to :user
  belongs_to :invited_by, class_name: "User", optional: true
  validates :joined_at, presence: true
  validates :user_id, uniqueness: { scope: :group_id, message: "is already a member of this group" }

  # Callbacks
  before_validation :set_joined_at, on: :create

  private

  def set_joined_at
    self.joined_at ||= Time.current
  end
end
