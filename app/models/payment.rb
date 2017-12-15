class Payment < ActiveRecord::Base
  belongs_to :invoice, inverse_of: :payments

  validates :invoice, presence: { message: 'is required' }
  validates :hours, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  def date_as_string
    format = '%m/%d/%Y'
    if self.date
      @date_as_string = self.date.strftime(format)
    else
      @date_as_string = nil
    end
  end

  def date_as_string=(string)
    @date_as_string = string
    self.date = Chronic.parse(string)
  end
end
