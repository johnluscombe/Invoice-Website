require_relative '../rails_helper'
require_relative '../support/login'

describe 'Navbar' do
  subject { page }

  describe 'admin' do
    let(:admin) { FactoryGirl.create(:admin) }

    before do
      login admin
    end

    it 'should have the right links' do
      should have_link('Users', href: users_path)
      should have_link('All Invoices', href: invoices_path(:all => true))
      should have_link('Pending Invoices', href: invoices_path(:pending_only => true))
      should_not have_link('Current Invoice')
      should_not have_link('Invoices', href: user_invoices_path(admin))
      should have_link('Welcome, ' + admin.fullname, href: edit_user_path(admin))
      should have_link('Edit Profile', href: edit_user_path(admin))
      should have_link('Log Out', href: logout_path)
    end

    describe 'Users link works properly' do
      before { click_link('Users', href: users_path) }
      it { should have_content('Employees') }
    end

    describe 'All Invoices link works properly' do
      before { click_link('All Invoices', href: invoices_path(:all => true)) }
      it { should have_content('All Invoices') }
    end

    describe 'Pending Invoices link works properly' do
      before { click_link('Pending Invoices', href: invoices_path(:pending_only => true)) }
      it { should have_content('Pending Invoices') }
    end

    describe 'Edit Profile link works properly' do
      before { click_link('Edit Profile', href: edit_user_path(admin)) }
      it { should have_content('Edit profile') }
    end

    describe 'Log Out link works properly' do
      before { click_link('Log Out', href: logout_path) }
      it { should have_content('Log In') }
      it 'Logs out the user' do
        expect { current_user.to eq(nil) }
      end
    end
  end

  describe 'manager' do
    let(:manager) { FactoryGirl.create(:manager) }

    before do
      login manager
    end

    it 'should have the right links' do
      should have_link('Users', href: users_path)
      should_not have_link('All Invoices', href: invoices_path(:all => true))
      should have_link('Pending Invoices', href: invoices_path(:pending_only => true))
      should_not have_link('Current Invoice')
      should_not have_link('Invoices', href: user_invoices_path(manager))
      should have_link('Welcome, ' + manager.fullname, href: edit_user_path(manager))
      should have_link('Edit Profile', href: edit_user_path(manager))
      should have_link('Log Out', href: logout_path)
    end

    describe 'Users link works properly' do
      before { click_link('Users', href: users_path) }
      it { should have_content('Employees') }
    end

    describe 'Pending Invoices link works properly' do
      before { click_link('Pending Invoices', href: invoices_path(:pending_only => true)) }
      it { should have_content('Pending Invoices') }
    end

    describe 'Edit Profile link works properly' do
      before { click_link('Edit Profile', href: edit_user_path(manager)) }
      it { should have_content('Edit profile') }
    end

    describe 'Log Out link works properly' do
      before { click_link('Log Out', href: logout_path) }
      it { should have_content('Log In') }
      it 'Logs out the user' do
        expect { current_user.to eq(nil) }
      end
    end
  end

  describe 'employee without any invoices' do
    let(:employee) { FactoryGirl.create(:employee) }

    before do
      login employee
    end

    it 'should have the right links' do
      should_not have_link('Users', href: users_path)
      should_not have_link('All Invoices', href: invoices_path(:all => true))
      should_not have_link('Pending Invoices', href: invoices_path(:pending_only => true))
      should_not have_link('Current Invoice')
      should have_link('Invoices', href: user_invoices_path(employee))
      should have_link('Welcome, ' + employee.fullname, href: edit_user_path(employee))
      should have_link('Edit Profile', href: edit_user_path(employee))
      should have_link('Log Out', href: logout_path)
    end

    describe 'Invoices link works properly' do
      before { click_link('Invoices', href: user_invoices_path(employee)) }
      it { should have_content('Invoices') }
    end

    describe 'Edit Profile link works properly' do
      before { click_link('Edit Profile', href: edit_user_path(employee)) }
      it { should have_content('Edit profile') }
    end

    describe 'Log Out link works properly' do
      before { click_link('Log Out', href: logout_path) }
      it { should have_content('Log In') }
      it 'Logs out the user' do
        expect { current_user.to eq(nil) }
      end
    end
  end

  describe 'employee with an invoice' do
    let(:employee) { FactoryGirl.create(:employee) }
    let!(:invoice) { FactoryGirl.create(:invoice, user: employee) }

    before do
      login employee
    end

    it 'should have the right links' do
      should_not have_link('Users', href: users_path)
      should_not have_link('All Invoices', href: invoices_path(:all => true))
      should_not have_link('Pending Invoices', href: invoices_path(:pending_only => true))
      should have_link('Current Invoice', href: invoice_payments_path(invoice))
      should have_link('Invoices', href: user_invoices_path(employee))
      should have_link('Welcome, ' + employee.fullname, href: edit_user_path(employee))
      should have_link('Edit Profile', href: edit_user_path(employee))
      should have_link('Log Out', href: logout_path)
    end

    describe 'Invoices link works properly' do
      before { click_link('Invoices', href: user_invoices_path(employee)) }
      it { should have_content('Invoices') }
    end

    describe 'Current Invoice link works properly' do
      before { click_link('Current Invoice', href: invoice_payments_path(invoice)) }
      it { should have_content('Payments for Invoice') }
    end

    describe 'Edit Profile link works properly' do
      before { click_link('Edit Profile', href: edit_user_path(employee)) }
      it { should have_content('Edit profile') }
    end

    describe 'Log Out link works properly' do
      before { click_link('Log Out', href: logout_path) }
      it { should have_content('Log In') }
      it 'Logs out the user' do
        expect { current_user.to eq(nil) }
      end
    end
  end
end