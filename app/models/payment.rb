class Payment < ActiveRecord::Base
  belongs_to :invoice, inverse_of: :payments
end
