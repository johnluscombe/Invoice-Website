class Payment < ActiveRecord::Base
  belongs_to :invoice, inverse_of: :payments

  validates :invoice, presence: true
  validates :hours, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
