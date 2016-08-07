require_relative '../../../rails_helper'
require_relative '../../../support/login'

describe 'Manager Invoices Permissions' do
  subject { page }

  describe 'manager' do
    let(:admin) { FactoryGirl.create(:admin) }
    let(:manager) { FactoryGirl.create(:manager) }
    let(:other_manager) { FactoryGirl.create(:manager) }
    let(:employee) { FactoryGirl.create(:employee) }

    before { login manager }

    describe 'invoices index of self' do
      before { visit user_invoices_path(manager) }

      it 'should give an error' do
        should have_current_path(users_path)
        should have_content 'User does not get paid hourly'
        should_not have_content 'You do not have permission to perform this action'
        should_not have_content 'Unable'
      end
    end

    describe 'invoices index of admin' do
      before { visit user_invoices_path(admin) }

      it 'should give an error' do
        should have_current_path(users_path)
        should have_content 'User does not get paid hourly'
        should_not have_content 'You do not have permission to perform this action'
        should_not have_content 'Unable'
      end
    end

    describe 'invoices index of another manager' do
      before { visit user_invoices_path(other_manager) }

      it 'should give an error' do
        should have_current_path(users_path)
        should have_content 'User does not get paid hourly'
        should_not have_content 'You do not have permission to perform this action'
        should_not have_content 'Unable'
      end
    end

    describe 'invoices index of employee' do
      before { visit user_invoices_path(employee) }

      it 'should load the page without error' do
        should have_current_path(user_invoices_path(employee))
        should_not have_content 'User does not get paid hourly'
        should_not have_content 'You do not have permission to perform this action'
        should_not have_content 'Unable'
      end
    end

    describe 'new invoice of self' do
      before { visit new_user_invoice_path(manager) }

      it 'should give an error' do
        should have_current_path(users_path)
        should have_content 'User does not get paid hourly'
        should_not have_content 'You do not have permission to perform this action'
        should_not have_content 'Unable'
      end
    end

    describe 'new invoice of admin' do
      before { visit new_user_invoice_path(admin) }

      it 'should give an error' do
        should have_current_path(users_path)
        should have_content 'User does not get paid hourly'
        should_not have_content 'You do not have permission to perform this action'
        should_not have_content 'Unable'
      end
    end

    describe 'new invoice of another manager' do
      before { visit new_user_invoice_path(other_manager) }

      it 'should give an error' do
        should have_current_path(users_path)
        should have_content 'User does not get paid hourly'
        should_not have_content 'You do not have permission to perform this action'
        should_not have_content 'Unable'
      end
    end

    describe 'new invoice of employee' do
      before { visit new_user_invoice_path(employee) }

      it 'should generate a new invoice and load the invoices index page' do
        should have_current_path(user_invoices_path(employee))
        should_not have_content 'User does not get paid hourly'
        should_not have_content 'You do not have permission to perform this action'
        should_not have_content 'Unable'
      end
    end

    describe 'edit invoice' do
      let(:invoice) { FactoryGirl.create(:invoice, user: employee) }

      before { visit edit_invoice_path(invoice) }

      it 'should load the page without error' do
        should have_current_path(edit_invoice_path(invoice))
        should_not have_content 'User does not get paid hourly'
        should_not have_content 'You do not have permission to perform this action'
        should_not have_content 'Unable'
      end
    end

    describe 'delete invoice' do
      let(:invoice) { FactoryGirl.create(:invoice, user: employee) }

      before { page.driver.submit :delete, invoice_path(invoice), {} }

      it 'should not have an error' do
        should have_current_path(user_invoices_path(employee))
        should_not have_content 'User does not get paid hourly'
        should_not have_content 'You do not have permission to perform this action'
        should_not have_content 'Unable'
      end
    end
  end
end