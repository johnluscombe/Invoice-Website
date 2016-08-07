require_relative '../../../rails_helper'
require_relative '../../../support/login'

describe 'Manager Payments Permissions' do
  subject { page }

  describe 'manager' do
    let(:manager) { FactoryGirl.create(:manager) }
    let(:employee) { FactoryGirl.create(:employee) }
    let(:invoice) { FactoryGirl.create(:invoice, user: employee) }

    before { login manager }

    describe 'payments index' do
      before { visit invoice_payments_path(invoice) }

      it 'should load the page without error' do
        should have_current_path(invoice_payments_path(invoice))
        should_not have_content 'You do not have permission to perform this action'
        should_not have_content 'Unable'
      end
    end

    describe 'new payment' do
      before { visit new_invoice_payment_path(invoice) }

      it 'should load the page without error' do
        should have_current_path(new_invoice_payment_path(invoice))
        should_not have_content 'You do not have permission to perform this action'
        should_not have_content 'Unable'
      end
    end

    describe 'edit payment' do
      let(:payment) { FactoryGirl.create(:payment, invoice: invoice) }

      before { visit edit_payment_path(payment) }

      it 'should load the page without error' do
        should have_current_path(edit_payment_path(payment))
        should_not have_content 'You do not have permission to perform this action'
        should_not have_content 'Unable'
      end
    end

    describe 'delete payment' do
      let(:payment) { FactoryGirl.create(:payment, invoice: invoice) }

      before { page.driver.submit :delete, payment_path(payment), {} }

      it 'should not have an error' do
        should have_current_path(invoice_payments_path(invoice))
        should_not have_content 'You do not have permission to perform this action'
        should_not have_content 'Unable'
      end
    end
  end
end