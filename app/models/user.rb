class User < ActiveRecord::Base
  has_many :invoices, inverse_of: :user

  has_secure_password

  before_destroy { self.invoices.destroy_all }

  validates :name, presence: { message: 'is required' }, uniqueness: true
  validates :rate, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :profile, presence: { message: 'is required' }

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
      invoice.get_net_pay
    elsif self.manager?
      'N/A'
    else
      '-'
    end
  end

  def self.create_user(user)
    if user.password_digest.nil?
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
      User.all.order(profile: :desc)
    else
      User.where(:profile => 1)
    end
  end
end
