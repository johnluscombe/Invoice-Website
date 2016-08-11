require_relative '../../rails_helper'
require_relative '../../support/login'

describe 'Employee Invoice Pages' do
  subject { page }

  describe 'employee' do
    let(:employee) { FactoryGirl.create(:employee) }
    let(:invoice) { FactoryGirl.create(:invoice, user: employee)}

    before do
      10.times { FactoryGirl.create(:payment, invoice: invoice) }
      login employee
    end

    it 'should have 10 payments' do
      expect(Payment.count).to eq(10)
    end

    describe 'list payments' do
      before { visit invoice_payments_path(invoice) }

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

      before do
        visit new_invoice_payment_path(invoice)
        fill_in 'payment_description', with: 'Test Description'
        fill_in 'payment_hours', with: 3
      end

      it "has the date filled in with today's date" do
        should have_field('payment_date_as_string', with: Date.today.strftime('%m-%d-%Y'))
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
          should have_current_path(invoice_payments_path(invoice))
          should have_selector('tr', text: Date.today.strftime('%m-%d-%Y') + ' Test Description 3.00 $ 30.00')
        end
      end

      describe 'clicking cancel' do
        it 'does not add the payment to the system' do
          expect { click_link cancel }.not_to change(Payment, :count)
        end

        it 'redirects to payments page' do
          click_link cancel
          should have_current_path(invoice_payments_path(invoice))
        end
      end
    end

    describe 'editing payments' do
      let(:submit) { 'UPDATE PAYMENT' }
      let(:cancel) { 'CANCEL' }
      let(:new_invoice) { FactoryGirl.create(:invoice, user: employee) }
      let(:payment) { FactoryGirl.create(:payment, invoice: new_invoice) }

      before { visit edit_payment_path(payment) }

      it 'has the correct fields' do
        should have_field('payment_date_as_string', with: payment.date_as_string)
        should have_field('payment_description', with: payment.description)
        should have_field('payment_hours', with: payment.hours)
        should_not have_field('payment_daily_rate')
      end

      describe 'with valid information' do
        before do
          fill_in 'payment_date_as_string', with: '2016-12-31'
          fill_in 'payment_description', with: 'Changed Description'
          fill_in 'payment_hours', with: 4
        end

        describe 'changes the data' do
          before { click_button submit }

          specify { expect(payment.reload.date).to eq('2016-12-31'.to_date) }
          specify { expect(payment.reload.description).to eq('Changed Description') }
          specify { expect(payment.reload.hours).to eq(4) }
        end

        it 'redirects back to payments page and shows payment' do
          click_button submit
          should have_current_path(invoice_payments_path(new_invoice))
          should have_selector('tr', text: '12-31-2016 Changed Description 4.00 $ 40.00')
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
          should have_current_path(invoice_payments_path(new_invoice))
        end
      end

      describe 'non-existant' do
        before { visit edit_payment_path(-1) }

        it { should have_content('Unable') }
      end
    end

    describe 'delete payments' do
      let!(:new_invoice) { FactoryGirl.create(:invoice, user: employee) }
      let!(:payment) { FactoryGirl.create(:payment, invoice: new_invoice) }

      before { visit invoice_payments_path(new_invoice) }

      it { should have_link('DELETE', href: payment_path(payment)) }

      it 'redirects properly' do
        click_link('DELETE', href: payment_path(payment))
        should have_current_path(invoice_payments_path(new_invoice))
      end

      it 'removes the payment from the system' do
        expect do
          click_link('DELETE', href: payment_path(payment))
        end.to change(Payment, :count).by(-1)
      end
    end

    describe "invoices with 'In Progress' status" do
      let!(:new_invoice) { FactoryGirl.create(:invoice, user: employee) }

      before do
        FactoryGirl.create(:payment, invoice: new_invoice)
        visit invoice_payments_path(new_invoice)
      end

      it 'shows the correct buttons' do
        should have_link('NEW PAYMENT', href: new_invoice_payment_path(new_invoice))
        should have_link('SUBMIT INVOICE', href: invoice_submit_path(new_invoice))
        should_not have_link('RESET INVOICE', href: invoice_reset_path(new_invoice))
      end
    end

    describe "invoices with 'Pending' status" do
      let!(:new_invoice) { FactoryGirl.create(:invoice, user: employee, status: 'Pending') }

      before do
        FactoryGirl.create(:payment, invoice: new_invoice)
        visit invoice_payments_path(new_invoice)
      end

      it 'shows the correct buttons' do
        should_not have_link('NEW PAYMENT', href: new_invoice_payment_path(new_invoice))
        should_not have_link('SUBMIT INVOICE', href: invoice_submit_path(new_invoice))
        should have_link('RESET INVOICE', href: invoice_reset_path(new_invoice))
      end
    end

    describe "invoices with 'Paid' status" do
      let!(:new_invoice) { FactoryGirl.create(:invoice, user: employee, status: 'Paid') }

      before do
        FactoryGirl.create(:payment, invoice: new_invoice)
        visit invoice_payments_path(new_invoice)
      end

      it 'shows the correct buttons' do
        should_not have_link('NEW PAYMENT', href: new_invoice_payment_path(new_invoice))
        should_not have_link('SUBMIT INVOICE', href: invoice_submit_path(new_invoice))
        should_not have_link('RESET INVOICE', href: invoice_reset_path(new_invoice))
      end
    end
  end
end