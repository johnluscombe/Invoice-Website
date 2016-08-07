class User < ActiveRecord::Base
  has_many :invoices, inverse_of: :user

  has_secure_password

  validates :name, presence: true, uniqueness: true
  validates :rate, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :profile, presence: true

  scope :managers, -> { where('profile >= ?', 2) }

  def employee?
    self.profile == 1
  end

  def manager?
    self.profile >= 2
  end

  def admin?
    self.profile == 3
  end

  def superior(user)
    self != user and self.profile > user.profile
  end

  def invoice
    self.invoices.where.not(:status => 'Paid').last
  end

  def net_pay
    invoice = self.invoice
    if invoice and self.employee?
      sum_hours_without_override = invoice.payments.where(:daily_rate => nil).sum(:hours)
      sum_daily_rate_with_override = invoice.payments.where.not(:daily_rate => nil).sum(:daily_rate)
      if invoice.net_pay == nil
        if invoice.rate == nil
          if invoice.hours == nil
            sprintf('%.2f', sum_hours_without_override * self.rate + sum_daily_rate_with_override)
          else
            sprintf('%.2f', invoice.hours * self.rate + sum_daily_rate_with_override)
          end
        else
          if invoice.hours == nil
            sprintf('%.2f', sum_hours_without_override * invoice.rate + sum_daily_rate_with_override)
          else
            sprintf('%.2f', invoice.hours * invoice.rate + sum_daily_rate_with_override)
          end
        end
      else
        sprintf('%.2f', invoice.net_pay)
      end
    elsif self.manager?
      'N/A'
    else
      '-'
    end
  end

  def self.create_user(user)
    if user.password_digest == nil
      user.password = 'password'
      user.password_confirmation = 'password'
    end
    user.save
  end

  def update_user(params, user_is_self)
    if user_is_self
      self.first_time = false
    end
    self.update(params)
  end

  def self.get_users(current_user)
    if current_user.admin?
      User.all.order(:fullname)
    else
      User.where(:profile => 1)
    end
  end
end
