class Invoice < ActiveRecord::Base
  belongs_to :user, inverse_of: :invoices
  has_many :payments, inverse_of: :invoice

  validates :user, presence: true
  validates :status, presence: true
  validates :hours, :net_pay, :rate, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :check_no, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  scope :not_submitted, -> { where(status: %w(Started In\ Progress)) }
  scope :pending, -> { where(:status => 'Pending') }
  scope :ordered, -> { order(:start_date).reverse_order }

  def started?
    self.status == 'Started'
  end

  def in_progress?
    self.status == 'In Progress'
  end

  def pending?
    self.status == 'Pending'
  end

  def paid?
    self.status == 'Paid'
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
