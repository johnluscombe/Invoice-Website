class Invoice < ActiveRecord::Base
  belongs_to :user, inverse_of: :invoices
  has_many :payments, inverse_of: :invoice

  validates :user, presence: true
  validates :status, presence: true
  validates :hours, :net_pay, :rate, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :check_no, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  def submit
    if self.end_date == nil
      self.update(:end_date => Date.today, :status => 'Pending')
    else
      self.update(:status => 'Pending')
    end
  end

  def reset
    self.update(:status => 'In Progress')
  end

  def pay
    self.update(:status => 'Paid', :transfer_date => Date.today)
  end
end
