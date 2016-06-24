require_relative '../../rails_helper'
require_relative '../../support/login'

describe 'Manager Invoice Pages' do
  subject { page }

  describe 'manager' do
    let(:manager) { FactoryGirl.create(:manager) }
    let(:employee) { FactoryGirl.create(:employee) }
    let(:invoice) { FactoryGirl.create(:invoice, user: employee)}

    before do
      10.times { FactoryGirl.create(:payment, invoice: invoice) }
      login manager
      visit invoice_payments_path(invoice)
    end

    it 'should have 10 payments' do
      expect(Payment.count).to eq(10)
    end

    describe 'list payments' do
      it 'should show all payments' do
        Payment.all.each do |payment|
          should_not have_selector('tr', text: payment.id.to_s + ' ' + payment.date.strftime('%m-%d-%Y'))
          should have_selector('tr', text: payment.description)
          should have_selector('tr', text: '3.00 $ 30.00')
          should have_link('EDIT')
          should have_link('DELETE')
        end
      end
    end

    describe 'new payment' do
      let(:submit) { 'NEW PAYMENT' }
      let(:cancel) { 'CANCEL' }

      before { visit new_invoice_payment_path(invoice) }

      before do
        fill_in 'payment_date', with: '2016-01-01'
        fill_in 'payment_description', with: 'Test Description'
        fill_in 'payment_hours', with: 3
      end

      describe 'with valid information' do
        it 'allows the user to fill in the fields' do
          click_button submit
        end

        it 'does add the payment to the system' do
          expect { click_button submit }.to change(Payment, :count).by(1)
        end

        it 'redirects to payments page and shows new payment' do
          click_button submit
          should have_content 'Payments for Invoice'
          should have_selector('tr', text: '01-01-2016 Test Description 3.00 $ 30.00')
        end
      end

      describe 'clicking cancel' do
        it 'does not add the payment to the system' do
          expect { click_link cancel }.not_to change(Payment, :count)
        end

        it 'redirects to payments page' do
          click_link cancel
          should have_content 'Payments for Invoice'
        end
      end
    end

    describe 'editing payments' do
      let(:submit) { 'UPDATE PAYMENT' }
      let(:cancel) { 'CANCEL' }
      let(:invoice) { FactoryGirl.create(:invoice, user: employee) }
      let(:payment) { FactoryGirl.create(:payment, invoice: invoice) }

      before do
        visit edit_payment_path(payment)
      end

      it 'has the correct fields' do
        should have_field('payment_date', with: payment.date)
        should have_field('payment_description', with: payment.description)
        should have_field('payment_hours', with: payment.hours)
        should have_field('payment_daily_rate')
      end

      describe 'with valid information' do
        before do
          fill_in 'payment_date', with: '2016-12-31'
          fill_in 'payment_description', with: 'Changed Description'
          fill_in 'payment_hours', with: 4
          fill_in 'payment_daily_rate', with: 15
        end

        describe 'changes the data' do
          before { click_button submit }

          specify { expect(payment.reload.date).to eq('2016-12-31'.to_date) }
          specify { expect(payment.reload.description).to eq('Changed Description') }
          specify { expect(payment.reload.hours).to eq(4) }
          specify { expect(payment.reload.daily_rate).to eq(15) }
        end

        it 'redirects back to payments page and shows payment' do
          click_button submit
          should have_content 'Payments for Invoice'
          should have_selector('tr', text: '12-31-2016 Changed Description 4.00 $ 15.00')
        end

        it 'does not add a new payment to the system' do
          expect { click_button submit }.not_to change(Payment, :count)
        end
      end

      describe 'clicking cancel' do
        it 'does not add the payment to the system' do
          expect { click_link cancel }.not_to change(Payment, :count)
        end

        it 'redirects to payment page' do
          click_link cancel
          should have_content 'Payments for Invoice'
        end
      end

      describe 'non-existant' do
        before do
          visit edit_payment_path(-1)
        end

        it { should have_content('Unable') }
      end
    end

    describe 'delete payments' do
      let!(:invoice) { FactoryGirl.create(:invoice, user: employee) }
      let!(:payment) { FactoryGirl.create(:payment, invoice: invoice) }

      before do
        visit invoice_payments_path(invoice)
      end

      it { should have_link('DELETE', href: payment_path(payment)) }

      it 'redirects properly' do
        click_link('DELETE', href: payment_path(payment))
        should have_content 'Payments for Invoice'
      end

      it 'removes the payment from the system' do
        expect do
          click_link('DELETE', href: payment_path(payment))
        end.to change(Payment, :count).by(-1)
      end
    end

    describe "invoices with 'Started' status" do
      let!(:invoice) { FactoryGirl.create(:invoice, user: employee) }

      before { visit invoice_payments_path(invoice) }

      it 'shows the correct buttons' do
        should have_link('NEW PAYMENT', href: new_invoice_payment_path(invoice))
        should_not have_link('SUBMIT INVOICE', href: edit_invoice_path(invoice, :submit => true, :from_payments => true))
        should_not have_link('RESET INVOICE', href: edit_invoice_path(invoice, :reset => true, :from_payments => true))
      end
    end

    describe "invoices with 'In Progress' status" do
      let!(:invoice) { FactoryGirl.create(:invoice, user: employee, status: 'In Progress') }

      before { visit invoice_payments_path(invoice) }

      it 'shows the correct buttons' do
        should have_link('NEW PAYMENT', href: new_invoice_payment_path(invoice))
        should have_link('SUBMIT INVOICE', href: edit_invoice_path(invoice, :submit => true, :from_payments => true))
        should_not have_link('RESET INVOICE', href: edit_invoice_path(invoice, :reset => true, :from_payments => true))
      end
    end

    describe "invoices with 'Pending' status" do
      let!(:invoice) { FactoryGirl.create(:invoice, user: employee, status: 'Pending') }

      before { visit invoice_payments_path(invoice) }

      it 'shows the correct buttons' do
        should_not have_link('NEW PAYMENT', href: new_invoice_payment_path(invoice))
        should_not have_link('SUBMIT INVOICE', href: edit_invoice_path(invoice, :submit => true, :from_payments => true))
        should have_link('RESET INVOICE', href: edit_invoice_path(invoice, :reset => true, :from_payments => true))
      end
    end

    describe "invoices with 'Paid' status" do
      let!(:invoice) { FactoryGirl.create(:invoice, user: employee, status: 'Paid') }

      before { visit invoice_payments_path(invoice) }

      it 'shows the correct buttons' do
        should_not have_link('NEW PAYMENT', href: new_invoice_payment_path(invoice))
        should_not have_link('SUBMIT INVOICE', href: edit_invoice_path(invoice, :submit => true, :from_payments => true))
        should_not have_link('RESET INVOICE', href: edit_invoice_path(invoice, :reset => true, :from_payments => true))
      end
    end
  end
end