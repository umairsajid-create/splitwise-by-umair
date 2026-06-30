
class Group < ApplicationRecord
  enum :group_type, { home: 0, trip: 1, couple: 2, other: 3 }

  has_one_attached :avatar

  belongs_to :creator, class_name: "User"
  has_many :group_members, dependent: :destroy
  has_many :members, through: :group_members, source: :user
  has_many :expenses, dependent: :destroy
  has_many :invitations, class_name: "GroupInvitation", dependent: :destroy
  has_many :default_splits, dependent: :destroy
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :group_type, presence: true

  scope :active, -> { where(is_active: true) }
  scope :archived, -> { where(is_active: false) }

  # Instance Methods
  def archive!
    update!(is_active: false)
  end

  def member?(user)
    group_members.exists?(user_id: user.id)
  end

  def admin?(user)
    group_members.exists?(user_id: user.id, role: :admin)
  end
end
