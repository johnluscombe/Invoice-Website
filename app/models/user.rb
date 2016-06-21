class User < ActiveRecord::Base
  has_many :invoices, inverse_of: :user

  has_secure_password

  validates :name, presence: true, uniqueness: true
  validates :rate, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  def self.get_users(current_user)
    if current_user.master
      User.all.order(:fullname)
    else
      User.where(:admin => false)
    end
  end
end
