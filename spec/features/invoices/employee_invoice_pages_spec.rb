require_relative '../../rails_helper'
require_relative '../../support/login'

describe 'Employee Invoice Pages' do
  subject { page }

  describe 'employee' do
    let(:employee) { FactoryGirl.create(:employee) }

    before do
      10.times { FactoryGirl.create(:invoice, user: employee) }
      login employee
      visit user_invoices_path(employee)
    end

    it 'should have 10 invoices' do
      expect(Invoice.count).to eq(10)
    end

    describe 'list invoices' do
      it 'should show all invoices' do
        Invoice.all.each do |invoice|
          should_not have_selector('tr', text: invoice.id.to_s + ' Started')
          should have_selector('tr', text: invoice.start_date.strftime('%m/%d/%y'))
          should_not have_selector('tr', text: employee.rate)
          should have_selector('tr', text: '0.00 $ 0.00 Started')
          should_not have_selector('tr', text: invoice.check_no)
          should have_link('VIEW PAYMENTS')
          should have_link('EDIT')
          should have_link('DELETE')
          should_not have_link('SUBMIT')
          should_not have_link('RESET')
          should_not have_link('MARK AS PAID')
        end
      end
    end

    describe 'new invoice' do
      let(:submit) { 'NEW INVOICE' }

      before { visit user_invoices_path(employee) }

      it 'does add the invoice to the system' do
        expect { click_link submit }.to change(Invoice, :count).by(1)
      end

      it 'shows the invoices page' do
        should have_content 'Invoices'
      end
    end

    describe 'editing invoices' do
      let(:submit) { 'UPDATE INVOICE' }
      let(:cancel) { 'CANCEL' }
      let(:invoice) { FactoryGirl.create(:invoice, user: employee) }

      before do
        visit edit_invoice_path(invoice)
      end

      it 'has the correct fields' do
        should have_field('invoice_start_date', with: invoice.start_date)
        should have_field('invoice_end_date')
        should_not have_field('invoice_status', with: invoice.status)
        should_not have_field('invoice_check_no')
        should_not have_content('Overrides')
        should_not have_field('invoice_hours')
        should_not have_field('invoice_rate')
        should_not have_field('invoice_net_pay')
      end

      describe 'with valid information' do
        before do
          fill_in 'invoice_start_date', with: '2016-12-30'
          fill_in 'invoice_end_date', with: '2016-12-31'
        end

        describe 'changes the data' do
          before { click_button submit }

          specify { expect(invoice.reload.start_date).to eq('2016-12-30'.to_date) }
          specify { expect(invoice.reload.end_date).to eq('2016-12-31'.to_date) }
        end

        it 'redirects back to invoices page and shows invoice' do
          click_button submit
          should have_content 'Invoices'
          should have_selector('tr', text: '12/30/16 - 12/31/16 0.00 $ 0.00 Started')
        end

        it 'does not add a new invoice to the system' do
          expect { click_button submit }.not_to change(Invoice, :count)
        end
      end

      describe 'clicking cancel' do
        it 'does not add the invoice to the system' do
          expect { click_link cancel }.not_to change(Invoice, :count)
        end

        it 'redirects to invoice page' do
          click_link cancel
          should have_content 'Invoices'
        end
      end

      describe 'non-existant' do
        before do
          visit edit_user_path(-1)
        end

        it { should have_content('Unable') }
      end
    end

    describe 'delete invoices' do
      let!(:invoice) { FactoryGirl.create(:invoice, user: employee) }

      before do
        visit user_invoices_path(employee)
      end

      it { should have_link('DELETE', href: invoice_path(invoice)) }

      it 'redirects properly' do
        click_link('DELETE', href: invoice_path(invoice))
        should have_content 'Invoices'
      end

      it 'removes the invoice from the system' do
        expect do
          click_link('DELETE', href: invoice_path(invoice))
        end.to change(Invoice, :count).by(-1)
      end
    end

    describe "invoices with 'Started' status" do
      let!(:invoice) { FactoryGirl.create(:invoice, user: employee) }

      before { visit user_invoices_path(employee) }

      it 'shows the correct buttons' do
        should have_link('VIEW PAYMENTS', href: invoice_payments_path(invoice))
        should_not have_link('VIEW INVOICE', href: invoice_payments_path(invoice))
        should_not have_link('MARK AS PAID', href: edit_invoice_path(invoice, :approve => true))
        should_not have_link('RESET', href: edit_invoice_path(invoice, :reset => true))
        should have_link('EDIT', href: edit_invoice_path(invoice))
        should have_link('DELETE', href: invoice_path(invoice))
        should_not have_link('SUBMIT', href: edit_invoice_path(invoice, :submit => true))
      end
    end

    describe "invoices with 'In Progress' status" do
      let!(:invoice) { FactoryGirl.create(:invoice, user: employee, status: 'In Progress') }

      before { visit user_invoices_path(employee) }

      it 'shows the correct buttons' do
        should have_link('VIEW PAYMENTS', href: invoice_payments_path(invoice))
        should_not have_link('VIEW INVOICE', href: invoice_payments_path(invoice))
        should_not have_link('MARK AS PAID', href: edit_invoice_path(invoice, :approve => true))
        should_not have_link('RESET', href: edit_invoice_path(invoice, :reset => true))
        should have_link('EDIT', href: edit_invoice_path(invoice))
        should have_link('DELETE', href: invoice_path(invoice))
        should have_link('SUBMIT', href: edit_invoice_path(invoice, :submit => true))
      end
    end

    describe "invoices with 'Pending' status" do
      let!(:invoice) { FactoryGirl.create(:invoice, user: employee, status: 'Pending') }

      before { visit user_invoices_path(employee) }

      it 'shows the correct buttons' do
        should_not have_link('VIEW PAYMENTS', href: invoice_payments_path(invoice))
        should have_link('VIEW INVOICE', href: invoice_payments_path(invoice))
        should_not have_link('MARK AS PAID', href: edit_invoice_path(invoice, :approve => true))
        should have_link('RESET', href: edit_invoice_path(invoice, :reset => true))
        should_not have_link('EDIT', href: edit_invoice_path(invoice))
        should_not have_link('DELETE', href: invoice_path(invoice))
        should_not have_link('SUBMIT', href: edit_invoice_path(invoice, :submit => true))
      end
    end

    describe "invoices with 'Paid' status" do
      let!(:invoice) { FactoryGirl.create(:invoice, user: employee, status: 'Paid') }

      before { visit user_invoices_path(employee) }

      it 'shows the correct buttons' do
        should_not have_link('VIEW PAYMENTS', href: invoice_payments_path(invoice))
        should have_link('VIEW INVOICE', href: invoice_payments_path(invoice))
        should_not have_link('MARK AS PAID', href: edit_invoice_path(invoice, :approve => true))
        should_not have_link('RESET', href: edit_invoice_path(invoice, :reset => true))
        should_not have_link('EDIT', href: edit_invoice_path(invoice))
        should_not have_link('DELETE', href: invoice_path(invoice))
        should_not have_link('SUBMIT', href: edit_invoice_path(invoice, :submit => true))
      end
    end
  end
end