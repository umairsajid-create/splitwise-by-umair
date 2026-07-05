class AdminUser < ApplicationRecord
  devise :database_authenticatable, :recoverable, :rememberable, :validatable

  validates :username, presence: true,
                       uniqueness: { case_sensitive: false },
                       length: { minimum: 3, maximum: 30 }

  def self.find_for_database_authentication(warden_conditions)
    Rails.logger.error "WARDEN FIND_FOR_AUTH: #{warden_conditions.inspect}"
    super
  end

  def valid_for_authentication?
    result = super
    Rails.logger.error "WARDEN VALID_FOR_AUTH? result=#{result.inspect}"
    result
  end
end
