class Invoice < ActiveRecord::Base
  belongs_to :user, inverse_of: :invoices
  has_many :payments, inverse_of: :invoice

  before_destroy { self.payments.destroy_all }

  validates :user, presence: { message: 'is required' }
  validates :status, presence: { message: 'is required' }
  validates :hours, :net_pay, :rate, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :check_no, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  scope :not_submitted, -> { where(status: 'Started') }
  scope :submitted, -> { where(:status => 'Submitted') }
  scope :ordered, -> { order(:start_date).reverse_order }

  def started?
    self.status == 'Started'
  end

  def submitted?
    self.status == 'Submitted'
  end

  def paid?
    self.status == 'Paid'
  end

  def start_date_as_string
    format = '%m/%d/%Y'
    if self.start_date
      @start_date_as_string = self.start_date.strftime(format)
    else
      @start_date_as_string = nil
    end
  end

  def start_date_as_string=(string)
    @start_date_as_string = string
    self.start_date = Chronic.parse(string)
  end

  def end_date_as_string
    format = '%m/%d/%Y'
    if self.end_date
      @end_date_as_string = self.end_date.strftime(format)
    else
      @end_date_as_string = nil
    end
  end

  def end_date_as_string=(string)
    @end_date_as_string = string
    self.end_date = Chronic.parse(string)
  end

  def transfer_date_as_string
    format = '%m/%d/%Y'
    if self.transfer_date
      @transfer_date_as_string = self.transfer_date.strftime(format)
    else
      @transfer_date_as_string = nil
    end
  end

  def transfer_date_as_string=(string)
    @transfer_date_as_string = string
    self.transfer_date = Chronic.parse(string)
  end

  def submit(submitter, body)
    if self.end_date.nil?
      self.update(:end_date => Date.today, :status => 'Submitted')
    else
      self.update(:status => 'Submitted')
    end
    send_submit_emails(submitter, body)
  end

  def reset
    self.update(:status => 'Started')
  end

  def pay(payer, body)
    if self.transfer_date.nil?
      self.update(:transfer_date => Date.today, :status => 'Paid')
    else
      self.update(:status => 'Paid')
    end
    subject = get_pay_subject(payer)
    send_email(self.user, subject, body)
  end

  def get_net_pay
    sum_hours_without_override = self.payments.where(:daily_rate => nil).sum(:hours)
    sum_daily_rate_with_override = self.payments.where.not(:daily_rate => nil).sum(:daily_rate)
    if self.net_pay.nil?
      if self.rate.nil?
        if self.hours.nil?
          sprintf('%.2f', sum_hours_without_override * self.user.rate + sum_daily_rate_with_override)
        else
          sprintf('%.2f', self.hours * self.user.rate + sum_daily_rate_with_override)
        end
      else
        if self.hours.nil?
          sprintf('%.2f', sum_hours_without_override * self.rate + sum_daily_rate_with_override)
        else
          sprintf('%.2f', self.hours * self.rate + sum_daily_rate_with_override)
        end
      end
    else
      sprintf('%.2f', self.net_pay)
    end
  end

  private

  def send_submit_emails(submitter, body)
    if submitter.employee?
      User.managers.each do |recipient|
        subject = get_submit_subject(submitter)
        send_email(recipient, subject, body)
      end
    end
  end

  def send_email(recipient, subject, body)
    if recipient.email
      ses = Aws::SES::Client.new(region: 'us-east-1',
                                 access_key_id: ENV['AWS_ACCESS_KEY_ID'],
                                 secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'])
      ses.send_email({
        destination: {
          to_addresses: [ recipient.email ]
        },
        message: {
          body: {
            html: {
              charset: 'UTF-8',
              data: body
            }
          },
          subject: {
            charset: 'UTF-8',
            data: subject
          }
        },
        source: "#{ENV['SOURCE_EMAIL_DISPLAY_NAME']} <#{ENV['SOURCE_EMAIL']}>"
      })
    end
  end

  def get_submit_subject(submitter)
    if submitter.fullname.nil?
      "#{submitter.name} submitted an invoice for $#{self.get_net_pay}"
    else
      "#{submitter.fullname} submitted an invoice for $#{self.get_net_pay}"
    end
  end

  def get_pay_subject(payer)
    if payer.fullname.nil?
      "#{payer.name} paid your invoice for $#{self.get_net_pay}"
    else
      "#{payer.fullname} paid your invoice for $#{self.get_net_pay}"
    end
  end
end
