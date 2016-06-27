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

    describe 'invoices index for self' do
      before { visit user_invoices_path(manager) }

      it 'should give an error' do
        should have_content 'Employees'
        should have_content 'User does not get paid hourly'
        should_not have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
      end
    end

    describe 'invoices index for admin' do
      before { visit user_invoices_path(admin) }

      it 'should give an error' do
        should have_content 'Employees'
        should have_content 'User does not get paid hourly'
        should_not have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
      end
    end

    describe 'invoices index for manager' do
      before { visit user_invoices_path(other_manager) }

      it 'should give an error' do
        should have_content 'Employees'
        should have_content 'User does not get paid hourly'
        should_not have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
      end
    end

    describe 'invoices index for employee' do
      before { visit user_invoices_path(employee) }

      it 'should load the page without error' do
        should have_content 'Invoices for'
        should_not have_content 'User does not get paid hourly'
        should_not have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
      end
    end

    describe 'invoice new for self' do
      before { visit new_user_invoice_path(manager) }

      it 'should give an error' do
        should have_content 'Employees'
        should have_content 'User does not get paid hourly'
        should_not have_content 'New invoice'
        should_not have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
      end
    end

    describe 'invoice new for admin' do
      before { visit new_user_invoice_path(admin) }

      it 'should give an error' do
        should have_content 'Employees'
        should have_content 'User does not get paid hourly'
        should_not have_content 'New invoice'
        should_not have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
      end
    end

    describe 'invoice new for manager' do
      before { visit new_user_invoice_path(other_manager) }

      it 'should give an error' do
        should have_content 'Employees'
        should have_content 'User does not get paid hourly'
        should_not have_content 'New invoice'
        should_not have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
      end
    end

    describe 'invoice new for employee' do
      before { visit new_user_invoice_path(employee) }

      it 'should generate a new invoice and load the invoices index page' do
        should have_content 'Invoices for'
        should_not have_content 'Employees'
        should_not have_content 'User does not get paid hourly'
        should_not have_content 'New invoice'
        should_not have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
      end
    end

    describe 'invoice edit' do
      let(:invoice) { FactoryGirl.create(:invoice, user: employee) }

      before { visit edit_invoice_path(invoice) }

      it 'should load the page without error' do
        should have_content 'Edit invoice'
        should_not have_content 'Employees'
        should_not have_content 'Invoices for'
        should_not have_content 'User does not get paid hourly'
        should_not have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
      end
    end

    describe 'invoice delete' do
      let(:invoice) { FactoryGirl.create(:invoice, user: employee) }

      before { page.driver.submit :delete, invoice_path(invoice), {} }

      it 'should not have an error' do
        should have_content 'Invoices for'
        should_not have_content 'Employees'
        should_not have_content 'User does not get paid hourly'
        should_not have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
        should_not have_content 'You cannot delete yourself'
      end
    end
  end
end