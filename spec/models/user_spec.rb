require_relative '../rails_helper'
require_relative '../support/login'

describe User do
  let(:employee) { FactoryGirl.create(:employee) }
  let(:manager) { FactoryGirl.create(:manager) }
  let(:admin) { FactoryGirl.create(:admin) }

  subject { employee }

  it { should respond_to(:fullname) }
  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:rate) }
  it { should respond_to(:password) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:authenticate) }
  it { should respond_to(:first_time) }
  it { should respond_to(:profile) }
  it { should respond_to(:invoices) }

  it { should be_valid }

  specify { expect(employee.profile).to eq(1) }
  specify { expect(manager.profile).to eq(2) }
  specify { expect(admin.profile).to eq(3) }

  describe 'empty username' do
    before { employee.name = '' }

    it { should_not be_valid }
  end

  describe 'accepts blank full name' do
    before { employee.fullname = '' }

    it { should be_valid }
  end

  describe 'accepts blank email' do
    before { employee.email = '' }

    it { should be_valid }
  end

  describe 'accepts blank rate' do
    before { employee.rate = '' }

    it { should be_valid }
  end

  describe 'accepts blank password' do
    before { employee.password = '' }

    it { should be_valid }
  end

  describe 'accepts blank first_time' do
    before { employee.first_time = '' }

    it { should be_valid }
  end

  describe 'blank profile' do
    before { employee.profile = '' }

    it { should_not be_valid }
  end

  describe 'duplicate name' do
    let(:duplicate) do
      d = employee
      d.email = 'duplicate@example.com'
      d.password = 'new_password'
      d
    end

    it 'is not allowed' do
      expect(duplicate).not_to be_valid
    end
  end
end