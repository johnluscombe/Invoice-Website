class Invoice < ActiveRecord::Base
  belongs_to :user, inverse_of: :invoices
  has_many :payments, inverse_of: :invoice

  validates :user, presence: { message: 'is required' }
  validates :status, presence: { message: 'is required' }
  validates :hours, :net_pay, :rate, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :check_no, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  scope :not_submitted, -> { where(status: 'In Progress') }
  scope :pending, -> { where(:status => 'Pending') }
  scope :ordered, -> { order(:start_date).reverse_order }

  def in_progress?
    self.status == 'In Progress'
  end

  def pending?
    self.status == 'Pending'
  end

  def paid?
    self.status == 'Paid'
  end

  def start_date_as_string
    if self.start_date
      @start_date_as_string = self.start_date.strftime('%m-%d-%Y')
    else
      @start_date_as_string = nil
    end
  end

  def start_date_as_string=(string)
    @start_date_as_string = string
    self.start_date = Chronic.parse(string)
  end

  def end_date_as_string
    if self.end_date
      @end_date_as_string = self.end_date.strftime('%m-%d-%Y')
    else
      @end_date_as_string = nil
    end
  end

  def end_date_as_string=(string)
    @end_date_as_string = string
    self.end_date = Chronic.parse(string)
  end

  def transfer_date_as_string
    if self.transfer_date
      @transfer_date_as_string = self.transfer_date.strftime('%m-%d-%Y')
    else
      @transfer_date_as_string = nil
    end
  end

  def transfer_date_as_string=(string)
    @transfer_date_as_string = string
    self.transfer_date = Chronic.parse(string)
  end

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

  def get_net_pay
    sum_hours_without_override = self.payments.where(:daily_rate => nil).sum(:hours)
    sum_daily_rate_with_override = self.payments.where.not(:daily_rate => nil).sum(:daily_rate)
    if self.net_pay == nil
      if self.rate == nil
        if self.hours == nil
          sprintf('%.2f', sum_hours_without_override * self.user.rate + sum_daily_rate_with_override)
        else
          sprintf('%.2f', self.hours * self.user.rate + sum_daily_rate_with_override)
        end
      else
        if self.hours == nil
          sprintf('%.2f', sum_hours_without_override * self.rate + sum_daily_rate_with_override)
        else
          sprintf('%.2f', self.hours * self.rate + sum_daily_rate_with_override)
        end
      end
    else
      sprintf('%.2f', self.net_pay)
    end
  end
end
