require_relative '../../rails_helper'
require_relative '../../support/login'

describe 'Admin Invoice Pages' do
  subject { page }

  describe 'admin' do
    let(:admin) { FactoryGirl.create(:admin) }
    let(:employee) { FactoryGirl.create(:employee) }

    before do
      10.times { FactoryGirl.create(:invoice, user: employee) }
      login admin
      visit user_invoices_path(employee)
    end

    it 'should have 10 invoices' do
      expect(Invoice.count).to eq(10)
    end

    describe 'list invoices' do
      it 'should show all invoices' do
        Invoice.all.each do |invoice|
          should have_selector('tr', text: invoice.id)
          should have_selector('tr', text: 'Started ' + invoice.start_date.strftime('%m/%d/%y'))
          should have_selector('tr', text: '0.00')
          should have_selector('tr', text: employee.rate)
          should have_selector('tr', text: '$ 0.00')
          should have_selector('tr', text: 'Started')
          should have_selector('tr', text: invoice.check_no)
          should have_link('VIEW PAYMENTS', href: invoice_payments_path(invoice))
          should have_link('EDIT', href: edit_invoice_path(invoice))
          should have_link('DELETE', href: invoice_path(invoice))
          should have_link('SUBMIT', href: invoice_submit_path(invoice))
          should_not have_link('RESET', href: invoice_reset_path(invoice))
          should_not have_link('MARK AS PAID', href: invoice_pay_path(invoice))
        end
      end

      it 'should have a new invoice button' do
        should have_link('NEW INVOICE', href: new_user_invoice_path(employee))
      end
    end

    describe 'new invoice' do
      let(:submit) { 'NEW INVOICE' }

      before { visit user_invoices_path(employee) }

      it 'does add the invoice to the system' do
        expect { click_link submit }.to change(Invoice, :count).by(1)
      end

      it 'shows the invoices page' do
        should have_current_path(user_invoices_path(employee))
      end
    end

    describe 'editing invoices' do
      let(:submit) { 'UPDATE INVOICE' }
      let(:cancel) { 'CANCEL' }
      let!(:invoice) { FactoryGirl.create(:invoice, user: employee) }

      before do
        visit user_invoices_path(employee)
        click_link('EDIT', href: edit_invoice_path(invoice))
      end

      it 'has the correct fields' do
        should have_field('invoice_start_date_as_string', with: invoice.start_date_as_string)
        should have_field('invoice_end_date_as_string')
        should have_field('invoice_status', with: invoice.status)
        should have_field('invoice_check_no')
        should have_content('Overrides')
        should have_field('invoice_hours')
        should have_field('invoice_rate')
        should have_field('invoice_net_pay')
      end

      describe 'with valid information' do
        before do
          fill_in 'invoice_start_date_as_string', with: '2016-12-30'
          fill_in 'invoice_end_date_as_string', with: '2016-12-31'
          select 'Started', from: 'invoice_status'
          fill_in 'invoice_check_no', with: '1234'
          fill_in 'invoice_hours', with: 1
          fill_in 'invoice_rate', with: 5
          fill_in 'invoice_net_pay', with: 15
        end

        describe 'changes the data' do
          before { click_button submit }

          specify { expect(invoice.reload.start_date).to eq('2016-12-30'.to_date) }
          specify { expect(invoice.reload.end_date).to eq('2016-12-31'.to_date) }
          specify { expect(invoice.reload.status).to eq('Started') }
          specify { expect(invoice.reload.check_no).to eq(1234) }
          specify { expect(invoice.reload.hours).to eq(1) }
          specify { expect(invoice.reload.rate).to eq(5) }
          specify { expect(invoice.reload.net_pay).to eq(15) }
        end

        it 'redirects back to invoices page and shows invoice' do
          click_button submit
          should have_current_path(user_invoices_path(employee))
          should have_selector('tr', text: '12/30/16 - 12/31/16 1.00 5.00 $ 15.00 Started 1234')
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
          should have_current_path(user_invoices_path(employee))
        end
      end

      describe 'non-existant' do
        before { visit edit_invoice_path(-1) }

        it { should have_content('Unable') }
      end
    end

    describe 'delete invoices' do
      let!(:invoice) { FactoryGirl.create(:invoice, user: employee) }

      before { visit user_invoices_path(employee) }

      it { should have_link('DELETE', href: invoice_path(invoice)) }

      it 'redirects properly' do
        click_link('DELETE', href: invoice_path(invoice))
        should have_current_path(user_invoices_path(employee))
      end

      it 'removes the invoice from the system' do
        expect do
          click_link('DELETE', href: invoice_path(invoice))
        end.to change(Invoice, :count).by(-1)
      end
    end

    describe 'all invoices link' do
      before { click_link('All Invoices', href: all_invoices_path) }

      Invoice.all.each do |invoice|
        should have_selector('tr', text: invoice.id)
        should have_selector('tr', text: invoice.user.fullname)
        should have_selector('tr', text: 'Started ' + invoice.start_date.strftime('%m/%d/%y'))
        should have_selector('tr', text: '0.00')
        should have_selector('tr', text: employee.rate)
        should have_selector('tr', text: '$ 0.00')
        should have_selector('tr', text: 'Started')
        should have_selector('tr', text: invoice.check_no)
        should have_link('VIEW PAYMENTS', href: invoice_payments_path(invoice))
        should have_link('EDIT', href: edit_invoice_path(invoice))
        should have_link('DELETE', href: invoice_path(invoice))
        should_not have_link('SUBMIT', href: invoice_submit_path(invoice))
        should_not have_link('RESET', href: invoice_reset_path(invoice))
        should_not have_link('MARK AS PAID', href: invoice_pay_path(invoice))
      end

      it 'should not have new invoice button' do
        should_not have_link('NEW EMPLOYEE', href: new_user_invoice_path(employee))
      end
    end

    describe 'submitted invoices link with no submitted invoices' do
      before { click_link('Submitted Invoices', href: submitted_invoices_path) }

      it 'should have no invoices' do
        should have_selector('p', text: 'There are no submitted invoices.')
      end

      it 'should not have new invoice button' do
        should_not have_link('NEW EMPLOYEE', href: new_user_invoice_path(employee))
      end
    end

    describe 'submitted invoices link with a submitted invoice' do
      let!(:invoice) { FactoryGirl.create(:invoice, user: employee) }

      before do
        visit new_invoice_payment_path(invoice)
        click_button('CREATE NEW PAYMENT')
        visit user_invoices_path(employee)
        click_link('SUBMIT', href: invoice_submit_path(invoice))
        click_link('Submitted Invoices', href: submitted_invoices_path)
      end

      it 'should only show one invoice' do
        Invoice.all.each do |invoice|
          if invoice.status == 'Submitted'
            should have_selector('tr', text: invoice.id.to_s + ' ' + invoice.user.fullname)
            should have_selector('tr', text: invoice.start_date.strftime('%m/%d/%y') + ' - ' + invoice.end_date.strftime('%m/%d/%y'))
            should have_selector('tr', text: '0.00')
            should have_selector('tr', text: employee.rate)
            should have_selector('tr', text: '$ 0.00')
            should have_selector('tr', text: 'Submitted')
            should have_selector('tr', text: invoice.check_no)
            should have_link('VIEW INVOICE', href: invoice_payments_path(invoice))
            should have_link('MARK AS PAID', href: invoice_pay_path(invoice))
            should have_link('RESET', href: invoice_reset_path(invoice))
            should have_link('EDIT', href: edit_invoice_path(invoice))
            should have_link('DELETE', href: invoice_path(invoice))
            should_not have_link('SUBMIT', href: invoice_submit_path(invoice))
          end
        end
        should_not have_content('Started')
      end

      it 'should not have new invoice button' do
        should_not have_link('NEW EMPLOYEE', href: new_user_invoice_path(employee))
      end
    end

    describe "invoices with 'Started' status" do
      let!(:invoice) { FactoryGirl.create(:invoice, user: employee, status: 'Started') }

      before { visit user_invoices_path(employee) }

      it 'shows the correct buttons' do
        should have_link('VIEW PAYMENTS', href: invoice_payments_path(invoice))
        should_not have_link('VIEW INVOICE', href: invoice_payments_path(invoice))
        should_not have_link('MARK AS PAID', href: invoice_pay_path(invoice))
        should_not have_link('RESET', href: invoice_reset_path(invoice))
        should have_link('EDIT', href: edit_invoice_path(invoice))
        should have_link('DELETE', href: invoice_path(invoice))
        should have_link('SUBMIT', href: invoice_submit_path(invoice))
      end
    end

    describe "invoices with 'Submitted' status" do
      let!(:invoice) { FactoryGirl.create(:invoice, user: employee, status: 'Submitted') }

      before { visit user_invoices_path(employee) }

      it 'shows the correct buttons' do
        should_not have_link('VIEW PAYMENTS', href: invoice_payments_path(invoice))
        should have_link('VIEW INVOICE', href: invoice_payments_path(invoice))
        should have_link('MARK AS PAID', href: invoice_pay_path(invoice))
        should have_link('RESET', href: invoice_reset_path(invoice))
        should have_link('EDIT', href: edit_invoice_path(invoice))
        should have_link('DELETE', href: invoice_path(invoice))
        should_not have_link('SUBMIT', href: invoice_submit_path(invoice))
      end
    end

    describe "invoices with 'Paid' status" do
      let!(:invoice) { FactoryGirl.create(:invoice, user: employee, status: 'Paid') }

      before { visit user_invoices_path(employee) }

      it 'shows the correct buttons' do
        should_not have_link('VIEW PAYMENTS', href: invoice_payments_path(invoice))
        should have_link('VIEW INVOICE', href: invoice_payments_path(invoice))
        should_not have_link('MARK AS PAID', href: invoice_pay_path(invoice))
        should have_link('RESET', href: invoice_reset_path(invoice))
        should have_link('EDIT', href: edit_invoice_path(invoice))
        should have_link('DELETE', href: invoice_path(invoice))
        should_not have_link('SUBMIT', href: invoice_submit_path(invoice))
      end
    end

    describe "'View Payments' button works properly" do
      let!(:invoice) { FactoryGirl.create(:invoice, user: employee) }

      before do
        visit user_invoices_path(employee)
        click_link('VIEW PAYMENTS', href: invoice_payments_path(invoice))
      end

      it { should have_content('Payments for Invoice') }
    end

    describe "'View Invoice' button works properly" do
      let!(:invoice) { FactoryGirl.create(:invoice, user: employee, status: 'Submitted') }

      before do
        visit user_invoices_path(employee)
        click_link('VIEW INVOICE', href: invoice_payments_path(invoice))
      end

      it { should have_content('Payments for Invoice') }
    end

    describe "'Mark as Paid' button works properly" do
      let!(:invoice) { FactoryGirl.create(:invoice, user: employee, status: 'Submitted') }

      before do
        visit user_invoices_path(employee)
        click_link('MARK AS PAID', href: invoice_pay_path(invoice))
      end

      it { should have_content('Invoices for') }
    end

    describe "'Submit' button works properly" do
      let!(:invoice) { FactoryGirl.create(:invoice, user: employee) }

      before do
        visit user_invoices_path(employee)
        click_link('SUBMIT', href: invoice_submit_path(invoice))
      end

      it { should have_content('Invoices for') }
    end

    describe "'Reset' button works properly" do
      let!(:invoice) { FactoryGirl.create(:invoice, user: employee, status: 'Submitted') }

      before do
        visit user_invoices_path(employee)
        click_link('RESET', href: invoice_reset_path(invoice))
      end

      it { should have_content('Invoices for') }
    end
  end
end