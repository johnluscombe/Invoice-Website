require_relative '../../../rails_helper'
require_relative '../../../support/login'

describe 'Admin Payments Permissions' do
  subject { page }

  describe 'admin' do
    let(:admin) { FactoryGirl.create(:admin) }
    let(:employee) { FactoryGirl.create(:employee) }
    let(:invoice) { FactoryGirl.create(:invoice, user: employee) }

    before { login admin }

    describe 'payments index' do
      before { visit invoice_payments_path(invoice) }

      it 'should load the page without error' do
        should have_content 'Payments for Invoice'
        should_not have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
      end
    end

    describe 'payments new' do
      before { visit new_invoice_payment_path(invoice) }

      it 'should load the page without error' do
        should have_content 'New payment'
        should_not have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
      end
    end

    describe 'payments edit' do
      let(:payment) { FactoryGirl.create(:payment, invoice: invoice) }

      before { visit edit_payment_path(payment) }

      it 'should load the page without error' do
        should have_content 'Edit payment'
        should_not have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
      end
    end

    describe 'payments delete' do
      let(:payment) { FactoryGirl.create(:payment, invoice: invoice) }

      before { page.driver.submit :delete, payment_path(payment), {} }

      it 'should not have an error' do
        should have_content 'Payments for Invoice'
        should_not have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
      end
    end
  end
end