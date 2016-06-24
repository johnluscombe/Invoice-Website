require_relative '../rails_helper'
require_relative '../support/login'

describe User do
  let(:invoice) { FactoryGirl.create(:invoice) }
  subject { invoice }

  it { should respond_to(:start_date) }
  it { should respond_to(:end_date) }
  it { should respond_to(:status) }
  it { should respond_to(:hours) }
  it { should respond_to(:net_pay) }
  it { should respond_to(:status_override) }
  it { should respond_to(:rate) }
  it { should respond_to(:check_no) }
  it { should respond_to(:transfer_date) }
  it { should respond_to(:user) }
  it { should respond_to(:payments) }

  it { should be_valid }

  describe 'required User relationship' do
    before { invoice.user_id = nil }

    it { should_not be_valid }
  end

  describe 'accepts blank start date' do
    before { invoice.start_date = '' }

    it { should be_valid }
  end

  describe 'accepts blank end date' do
    before { invoice.end_date = '' }

    it { should be_valid }
  end

  describe 'blank status' do
    before { invoice.status = '' }

    it { should_not be_valid }
  end

  describe 'accepts blank hours' do
    before { invoice.hours = '' }

    it { should be_valid }
  end

  describe 'accepts blank net pay' do
    before { invoice.net_pay = '' }

    it { should be_valid }
  end

  describe 'accepts blank status override' do
    before { invoice.status_override = '' }

    it { should be_valid }
  end

  describe 'accepts blank rate' do
    before { invoice.rate = '' }

    it { should be_valid }
  end

  describe 'accepts blank check no' do
    before { invoice.check_no = '' }

    it { should be_valid }
  end

  describe 'accepts blank transfer date' do
    before { invoice.transfer_date = '' }

    it { should be_valid }
  end

  describe 'accepts duplicate invoices' do
    let(:duplicate) do
      d = invoice
      d.start_date = '2016-12-28'
      d.end_date = '2016-12-29'
      d
    end

    it 'is allowed' do
      expect(duplicate).to be_valid
    end
  end
end