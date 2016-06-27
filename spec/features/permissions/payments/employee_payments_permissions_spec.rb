require_relative '../../../rails_helper'
require_relative '../../../support/login'

describe 'Employee Payments Permissions' do
  subject { page }

  describe 'employee' do
    let(:employee) { FactoryGirl.create(:employee) }
    let(:other_employee) { FactoryGirl.create(:employee) }
    let(:invoice) { FactoryGirl.create(:invoice, user: employee) }
    let(:other_invoice) { FactoryGirl.create(:invoice, user: other_employee) }

    before { login employee }

    describe 'payments index for self' do
      before { visit invoice_payments_path(invoice) }

      it 'should load the page without error' do
        should have_content 'Payments for Invoice'
        should_not have_content 'You do not have permission'
        should_not have_content 'Unable'
      end
    end

    describe 'payments index for employee' do
      before { visit invoice_payments_path(other_invoice) }

      it 'should load the page without error' do
        should_not have_content 'Payments for Invoice'
        should have_content 'You do not have permission'
        should_not have_content 'Unable'
      end
    end

    describe 'payments new for self' do
      before { visit new_invoice_payment_path(invoice) }

      it 'should load the page without error' do
        should have_content 'New payment'
        should_not have_content 'You do not have permission'
        should_not have_content 'Unable'
      end
    end

    describe 'payments new for employee' do
      before { visit new_invoice_payment_path(other_invoice) }

      it 'should load the page without error' do
        should_not have_content 'New payment'
        should have_content 'You do not have permission'
        should_not have_content 'Unable'
      end
    end

    describe 'payments edit for self' do
      let(:payment) { FactoryGirl.create(:payment, invoice: invoice) }

      before { visit edit_payment_path(payment) }

      it 'should load the page without error' do
        should have_content 'Edit payment'
        should_not have_content 'You do not have permission'
        should_not have_content 'Unable'
      end
    end

    describe 'payments edit for employee' do
      let(:payment) { FactoryGirl.create(:payment, invoice: other_invoice) }

      before { visit edit_payment_path(payment) }

      it 'should load the page without error' do
        should_not have_content 'Edit payment'
        should have_content 'You do not have permission'
        should_not have_content 'Unable'
      end
    end

    describe 'payments delete for self' do
      let(:payment) { FactoryGirl.create(:payment, invoice: invoice) }

      before { page.driver.submit :delete, payment_path(payment), {} }

      it 'should not have an error' do
        should have_content 'Payments for Invoice'
        should_not have_content 'You do not have permission'
        should_not have_content 'Unable'
      end
    end

    describe 'payments delete for employee' do
      let(:payment) { FactoryGirl.create(:payment, invoice: other_invoice) }

      before { page.driver.submit :delete, payment_path(payment), {} }

      it 'should not have an error' do
        should_not have_content 'Payments for Invoice'
        should have_content 'You do not have permission'
        should_not have_content 'Unable'
      end
    end
  end
end