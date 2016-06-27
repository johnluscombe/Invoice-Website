require_relative '../../../rails_helper'
require_relative '../../../support/login'

describe 'Employee Invoices Permissions' do
  subject { page }

  describe 'employee' do
    let(:admin) { FactoryGirl.create(:admin) }
    let(:manager) { FactoryGirl.create(:manager) }
    let(:employee) { FactoryGirl.create(:employee) }
    let(:other_employee) { FactoryGirl.create(:employee) }

    before { login employee }

    describe 'invoices index for self' do
      before { visit user_invoices_path(employee) }

      it 'should load the page without error' do
        should_not have_content 'Employees'
        should_not have_content 'Invoices for'
        should_not have_content 'User does not get paid hourly'
        should_not have_content 'You do not have permission'
        should_not have_content 'Unable'
      end
    end

    describe 'invoices index for admin' do
      before { visit user_invoices_path(admin) }

      it 'should give an error' do
        should_not have_content 'Employees'
        should_not have_content 'Invoices for'
        should have_content 'You do not have permission'
        should_not have_content 'Unable'
      end
    end

    describe 'invoices index for manager' do
      before { visit user_invoices_path(manager) }

      it 'should give an error' do
        should_not have_content 'Employees'
        should_not have_content 'Invoices for'
        should have_content 'You do not have permission'
        should_not have_content 'Unable'
      end
    end

    describe 'invoices index for employee' do
      before { visit user_invoices_path(other_employee) }

      it 'should give an error' do
        should_not have_content 'Employees'
        should_not have_content 'Invoices for'
        should have_content 'You do not have permission'
        should_not have_content 'User does not get paid hourly'
        should_not have_content 'Unable'
      end
    end

    describe 'invoice new for self' do
      before { visit new_user_invoice_path(employee) }

      it 'should generate a new invoice and load the invoices index page' do
        should_not have_content 'Invoices for'
        should_not have_content 'Employees'
        should_not have_content 'User does not get paid hourly'
        should_not have_content 'New invoice'
        should_not have_content 'You do not have permission'
        should_not have_content 'Unable'
      end
    end

    describe 'invoice new for admin' do
      before { visit new_user_invoice_path(admin) }

      it 'should give an error' do
        should_not have_content 'Invoices for'
        should_not have_content 'Employees'
        should_not have_content 'New invoice'
        should have_content 'You do not have permission'
        should_not have_content 'Unable'
      end
    end

    describe 'invoice new for manager' do
      before { visit new_user_invoice_path(manager) }

      it 'should give an error' do
        should_not have_content 'Invoices for'
        should_not have_content 'Employees'
        should_not have_content 'New invoice'
        should have_content 'You do not have permission'
        should_not have_content 'Unable'
      end
    end

    describe 'invoice new for employee' do
      before { visit new_user_invoice_path(other_employee) }

      it 'should give an error' do
        should_not have_content 'Invoices for'
        should_not have_content 'Employees'
        should_not have_content 'New invoice'
        should have_content 'You do not have permission'
        should_not have_content 'User does not get paid hourly'
        should_not have_content 'Unable'
      end
    end

    describe 'invoice edit for self' do
      let(:invoice) { FactoryGirl.create(:invoice, user: employee) }

      before { visit edit_invoice_path(invoice) }

      it 'should load the page without error' do
        should have_content 'Edit invoice'
        should_not have_content 'Employees'
        should_not have_content 'Invoices for'
        should_not have_content 'User does not get paid hourly'
        should_not have_content 'You do not have permission'
        should_not have_content 'Unable'
      end
    end

    describe 'invoice edit for employee' do
      let(:invoice) { FactoryGirl.create(:invoice, user: other_employee) }

      before { visit edit_invoice_path(invoice) }

      it 'should give an error' do
        should_not have_content 'Edit invoice'
        should_not have_content 'Employees'
        should_not have_content 'Invoices for'
        should_not have_content 'User does not get paid hourly'
        should have_content 'You do not have permission'
        should_not have_content 'Unable'
      end
    end

    describe 'invoice delete for self' do
      let(:invoice) { FactoryGirl.create(:invoice, user: employee) }

      before { page.driver.submit :delete, invoice_path(invoice), {} }

      it 'should not have an error' do
        should_not have_content 'Employees'
        should_not have_content 'Invoices for'
        should_not have_content 'User does not get paid hourly'
        should_not have_content 'You do not have permission'
        should_not have_content 'Unable'
      end
    end

    describe 'invoice delete for employee' do
      let(:invoice) { FactoryGirl.create(:invoice, user: other_employee) }

      before { page.driver.submit :delete, invoice_path(invoice), {} }

      it 'should give an error' do
        should_not have_content 'Employees'
        should_not have_content 'Invoices for'
        should_not have_content 'User does not get paid hourly'
        should have_content 'You do not have permission'
        should_not have_content 'Unable'
      end
    end
  end
end