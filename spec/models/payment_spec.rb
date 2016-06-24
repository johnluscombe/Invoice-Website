require_relative '../rails_helper'
require_relative '../support/login'

describe User do
  let(:payment) { FactoryGirl.create(:payment) }
  subject { payment }

  it { should respond_to(:date) }
  it { should respond_to(:description) }
  it { should respond_to(:hours) }
  it { should respond_to(:daily_rate) }
  it { should respond_to(:invoice) }

  it { should be_valid }

  describe 'required Invoice relationship' do
    before { payment.invoice_id = nil }

    it { should_not be_valid }
  end

  describe 'accepts blank date' do
    before { payment.date = '' }

    it { should be_valid }
  end

  describe 'accepts blank description' do
    before { payment.description = '' }

    it { should be_valid }
  end

  describe 'accepts blank hours' do
    before { payment.hours = '' }

    it { should be_valid }
  end

  describe 'accepts blank daily rate' do
    before { payment.daily_rate = '' }

    it { should be_valid }
  end

  describe 'accepts duplicate payments' do
    let(:duplicate) do
      d = payment
      d.description = 'Testing 2'
      d.hours = 2
      d
    end

    it 'is allowed' do
      expect(duplicate).to be_valid
    end
  end
end