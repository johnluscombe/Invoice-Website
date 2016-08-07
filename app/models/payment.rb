class Payment < ActiveRecord::Base
  belongs_to :invoice, inverse_of: :payments

  validates :invoice, presence: true
  validates :hours, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  after_save :update_invoice

  def update_invoice
    if self.invoice.status == 'Started'
      self.invoice.update(:status => 'In Progress')
    end
  end
end
