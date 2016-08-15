require_relative '../rails_helper'
require_relative '../support/login'

describe 'Navbar' do
  subject { page }

  describe 'admin' do
    let(:admin) { FactoryGirl.create(:admin) }
    let(:employee) { FactoryGirl.create(:employee) }

    before { login admin }

    it 'should have the right links' do
      should have_link('Users', href: users_path)
      should have_link('All Invoices', href: all_invoices_path)
      should have_link('Submitted Invoices', href: submitted_invoices_path)
      should_not have_link('Current Invoice')
      should_not have_link('Invoices', href: user_invoices_path(admin))
      should have_link('Welcome, ' + admin.fullname, href: edit_user_path(admin))
      should have_link('Edit Profile', href: edit_user_path(admin))
      should have_link('Log Out', href: logout_path)
    end

    describe 'Users link works properly' do
      before { click_link('Users', href: users_path) }
      it { should have_current_path(users_path) }
    end

    describe 'All Invoices link works properly' do
      before { click_link('All Invoices', href: all_invoices_path) }
      it { should have_current_path(all_invoices_path) }
    end

    describe 'Submitted Invoices link works properly' do
      before { click_link('Submitted Invoices', href: submitted_invoices_path) }
      it { should have_current_path(submitted_invoices_path) }
    end

    describe 'Submitted Invoices with 1 submitted invoice' do
      before do
        FactoryGirl.create(:invoice, user: employee, status: 'Submitted')
        visit current_path
      end

      it { should have_content('Submitted Invoices 1') }
    end

    describe 'Submitted Invoices with no submitted invoices' do
      before { visit current_path }

      it { should_not have_content('Submitted Invoices 0') }
    end

    describe 'Current Invoice link does not appear' do
      it { should_not have_link('Current Invoice') }
    end

    describe 'Edit Profile link works properly' do
      before { click_link('Edit Profile', href: edit_user_path(admin)) }
      it { should have_current_path(edit_user_path(admin)) }
    end

    describe 'Log Out link works properly' do
      before { click_link('Log Out', href: logout_path) }
      it { should have_current_path(login_path) }
      it 'Logs out the user' do
        expect { current_user.to eq(nil) }
      end
    end
  end

  describe 'manager' do
    let(:manager) { FactoryGirl.create(:manager) }

    before { login manager }

    it 'should have the right links' do
      should have_link('Users', href: users_path)
      should_not have_link('All Invoices', href: all_invoices_path)
      should have_link('Submitted Invoices', href: submitted_invoices_path)
      should_not have_link('Current Invoice')
      should_not have_link('Invoices', href: user_invoices_path(manager))
      should have_link('Welcome, ' + manager.fullname, href: edit_user_path(manager))
      should have_link('Edit Profile', href: edit_user_path(manager))
      should have_link('Log Out', href: logout_path)
    end

    describe 'Users link works properly' do
      before { click_link('Users', href: users_path) }
      it { should have_current_path(users_path) }
    end

    describe 'All Invoices link does not appear' do
      it { should_not have_link('All Invoices') }
    end

    describe 'Submitted Invoices link works properly' do
      before { click_link('Submitted Invoices', href: submitted_invoices_path) }
      it { should have_current_path(submitted_invoices_path) }
    end

    describe 'Current Invoice link does not appear' do
      it { should_not have_link('Current Invoice') }
    end

    describe 'Edit Profile link works properly' do
      before { click_link('Edit Profile', href: edit_user_path(manager)) }
      it { should have_current_path(edit_user_path(manager)) }
    end

    describe 'Log Out link works properly' do
      before { click_link('Log Out', href: logout_path) }
      it { should have_current_path(login_path) }
      it 'Logs out the user' do
        expect { current_user.to eq(nil) }
      end
    end
  end

  describe 'employee without any invoices' do
    let(:employee) { FactoryGirl.create(:employee) }

    before { login employee }

    it 'should have the right links' do
      should_not have_link('Users', href: users_path)
      should_not have_link('All Invoices', href: all_invoices_path)
      should_not have_link('Submitted Invoices', href: submitted_invoices_path)
      should_not have_link('Current Invoice')
      should have_link('Invoices', href: user_invoices_path(employee))
      should have_link('Welcome, ' + employee.fullname, href: edit_user_path(employee))
      should have_link('Edit Profile', href: edit_user_path(employee))
      should have_link('Log Out', href: logout_path)
    end

    describe 'Users link does not appear' do
      it { should_not have_link('Users') }
    end

    describe 'Invoices link works properly' do
      before { click_link('Invoices', href: user_invoices_path(employee)) }
      it { should have_current_path(user_invoices_path(employee)) }
    end

    describe 'All Invoices link does not appear' do
      it { should_not have_link('All Invoices') }
    end

    describe 'Submitted Invoices link does not appear' do
      it { should_not have_link('Submitted Invoices') }
    end

    describe 'Current Invoice link does not appear' do
      it { should_not have_link('Current Invoice') }
    end

    describe 'Edit Profile link works properly' do
      before { click_link('Edit Profile', href: edit_user_path(employee)) }
      it { should have_current_path(edit_user_path(employee)) }
    end

    describe 'Log Out link works properly' do
      before { click_link('Log Out', href: logout_path) }
      it { should have_current_path(login_path) }
      it 'Logs out the user' do
        expect { current_user.to eq(nil) }
      end
    end
  end

  describe 'employee with an invoice' do
    let(:employee) { FactoryGirl.create(:employee) }
    let!(:invoice) { FactoryGirl.create(:invoice, user: employee) }

    before { login employee }

    it 'should have the right links' do
      should_not have_link('Users', href: users_path)
      should_not have_link('All Invoices', href: all_invoices_path)
      should_not have_link('Submitted Invoices', href: submitted_invoices_path)
      should have_link('Current Invoice', href: invoice_payments_path(invoice))
      should have_link('Invoices', href: user_invoices_path(employee))
      should have_link('Welcome, ' + employee.fullname, href: edit_user_path(employee))
      should have_link('Edit Profile', href: edit_user_path(employee))
      should have_link('Log Out', href: logout_path)
    end

    describe 'Users link does not appear' do
      it { should_not have_link('Users') }
    end

    describe 'Invoices link works properly' do
      before { click_link('Invoices', href: user_invoices_path(employee)) }
      it { should have_current_path(user_invoices_path(employee)) }
    end

    describe 'All Invoices link does not appear' do
      it { should_not have_link('All Invoices') }
    end

    describe 'Submitted Invoices link does not appear' do
      it { should_not have_link('Submitted Invoices') }
    end

    describe 'Current Invoice link works properly' do
      before { click_link('Current Invoice', href: invoice_payments_path(invoice)) }
      it { should have_current_path(invoice_payments_path(invoice)) }
    end

    describe 'Edit Profile link works properly' do
      before { click_link('Edit Profile', href: edit_user_path(employee)) }
      it { should have_current_path(edit_user_path(employee)) }
    end

    describe 'Log Out link works properly' do
      before { click_link('Log Out', href: logout_path) }
      it { should have_current_path(login_path) }
      it 'Logs out the user' do
        expect { current_user.to eq(nil) }
      end
    end
  end
end