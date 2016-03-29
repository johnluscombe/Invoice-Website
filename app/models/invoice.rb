class Invoice < ActiveRecord::Base
  belongs_to :user, inverse_of: :invoices
  has_many :payments, inverse_of: :invoice

  validates :user, presence: true
  validates :status, presence: true
  validates :hours, :net_pay, :rate, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :check_no, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
