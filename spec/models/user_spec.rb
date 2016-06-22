require_relative '../rails_helper'
require_relative '../support/login'

describe User do
  let(:user) { FactoryGirl.create(:employee) }
  subject { user }

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
  specify { expect(user.profile).to eq(1) }

  describe 'empty username' do
    before { user.name = '' }

    it { should_not be_valid }
  end

  describe 'accepts blank full name' do
    before { user.fullname = '' }

    it { should be_valid }
  end

  describe 'accepts blank email' do
    before { user.email = '' }

    it { should be_valid }
  end

  describe 'accepts blank rate' do
    before { user.rate = '' }

    it { should be_valid }
  end

  describe 'accepts blank password' do
    before { user.password = '' }

    it { should be_valid }
  end

  describe 'accepts blank first_time' do
    before { user.first_time = '' }

    it { should be_valid }
  end

  describe 'duplicate name' do
    let(:duplicate) do
      d = user
      d.email = 'duplicate@example.com'
      d.password = 'new_password'
      d
    end

    it 'is not allowed' do
      expect(duplicate).not_to be_valid
    end
  end

  describe 'manager account' do
    let (:manager) { FactoryGirl.create(:manager) }

    specify { expect(manager.profile).to eq(2) }
  end

  describe 'administrator account' do
    let (:admin) { FactoryGirl.create(:admin) }

    specify { expect(admin.profile).to eq(3) }
  end
end