require_relative '../rails_helper'
require_relative '../support/login'

describe 'Breadcrumb' do
  subject { page }

  describe 'admin' do
    let(:admin) { FactoryGirl.create(:admin) }
    let(:employee) { FactoryGirl.create(:employee) }
    let(:invoice) { FactoryGirl.create(:invoice, user: employee) }
    let(:payment) { FactoryGirl.create(:payment, invoice: invoice) }

    before { login admin }

    describe 'users' do
      describe 'index page' do
        it 'has the correct elements' do
          should have_selector('li.breadcrumb-item.active', text: 'Employees')
          should_not have_selector('li.breadcrumb-item', text: 'New User')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Profile')
          should_not have_selector('li.breadcrumb-item', text: 'Invoices')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Invoice')
          should_not have_selector('li.breadcrumb-item', text: 'Payments')
          should_not have_selector('li.breadcrumb-item', text: 'New Payment')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Payment')
        end
      end

      describe 'new page' do
        before { visit new_user_path }

        it 'has the correct elements' do
          should have_selector('li.breadcrumb-item', text: 'Employees')
          should have_selector('li.breadcrumb-item.active', text: 'New User')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Profile')
          should_not have_selector('li.breadcrumb-item', text: 'Invoices')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Invoice')
          should_not have_selector('li.breadcrumb-item', text: 'Payments')
          should_not have_selector('li.breadcrumb-item', text: 'New Payment')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Payment')
        end

        it 'redirects to index page properly' do
          find('li.breadcrumb-item', text: 'Employees').find('a').click
          should have_current_path(users_path)
        end
      end

      describe 'edit page' do
        before { visit edit_user_path(employee) }

        it 'has the correct elements' do
          should have_selector('li.breadcrumb-item', text: 'Employees')
          should_not have_selector('li.breadcrumb-item', text: 'New User')
          should have_selector('li.breadcrumb-item.active', text: 'Edit Profile')
          should_not have_selector('li.breadcrumb-item', text: 'Invoices')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Invoice')
          should_not have_selector('li.breadcrumb-item', text: 'Payments')
          should_not have_selector('li.breadcrumb-item', text: 'New Payment')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Payment')
        end

        it 'redirects to index page properly' do
          find('li.breadcrumb-item', text: 'Employees').find('a').click
          should have_current_path(users_path)
        end
      end
    end

    describe 'invoices' do
      describe 'index page' do
        before { visit user_invoices_path(employee) }

        it 'has the correct elements' do
          should have_selector('li.breadcrumb-item', text: 'Employees')
          should_not have_selector('li.breadcrumb-item', text: 'New User')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Profile')
          should have_selector('li.breadcrumb-item.active', text: 'Invoices')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Invoice')
          should_not have_selector('li.breadcrumb-item', text: 'Payments')
          should_not have_selector('li.breadcrumb-item', text: 'New Payment')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Payment')
        end

        it 'redirects to users index page properly' do
          find('li.breadcrumb-item', text: 'Employees').find('a').click
          should have_current_path(users_path)
        end
      end

      describe 'edit page' do
        before { visit edit_invoice_path(invoice) }

        it 'has the correct elements' do
          should have_selector('li.breadcrumb-item', text: 'Employees')
          should_not have_selector('li.breadcrumb-item', text: 'New User')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Profile')
          should have_selector('li.breadcrumb-item', text: 'Invoices')
          should have_selector('li.breadcrumb-item.active', text: 'Edit Invoice')
          should_not have_selector('li.breadcrumb-item', text: 'Payments')
          should_not have_selector('li.breadcrumb-item', text: 'New Payment')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Payment')
        end

        it 'redirects to invoices index page properly' do
          find('li.breadcrumb-item', text: 'Invoices').find('a').click
          should have_current_path(user_invoices_path(employee))
        end

        it 'redirects to user index page properly' do
          find('li.breadcrumb-item', text: 'Employees').find('a').click
          should have_current_path(users_path)
        end
      end
    end

    describe 'payments' do
      describe 'index page' do
        before { visit invoice_payments_path(invoice) }

        it 'has the correct elements' do
          should have_selector('li.breadcrumb-item', text: 'Employees')
          should_not have_selector('li.breadcrumb-item', text: 'New User')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Profile')
          should have_selector('li.breadcrumb-item', text: 'Invoices')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Invoice')
          should have_selector('li.breadcrumb-item.active', text: 'Payments')
          should_not have_selector('li.breadcrumb-item', text: 'New Payment')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Payment')
        end

        it 'redirects to invoices index page properly' do
          find('li.breadcrumb-item', text: 'Invoices').find('a').click
          should have_current_path(user_invoices_path(employee))
        end

        it 'redirects to user index page properly' do
          find('li.breadcrumb-item', text: 'Employees').find('a').click
          should have_current_path(users_path)
        end
      end

      describe 'new page' do
        before { visit new_invoice_payment_path(invoice) }

        it 'has the correct elements' do
          should have_selector('li.breadcrumb-item', text: 'Employees')
          should_not have_selector('li.breadcrumb-item', text: 'New User')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Profile')
          should have_selector('li.breadcrumb-item', text: 'Invoices')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Invoice')
          should have_selector('li.breadcrumb-item', text: 'Payments')
          should have_selector('li.breadcrumb-item.active', text: 'New Payment')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Payment')
        end

        it 'redirects to payments index page properly' do
          find('li.breadcrumb-item', text: 'Payments').find('a').click
          should have_current_path(invoice_payments_path(invoice))
        end

        it 'redirects to invoices index page properly' do
          find('li.breadcrumb-item', text: 'Invoices').find('a').click
          should have_current_path(user_invoices_path(employee))
        end

        it 'redirects to user index page properly' do
          find('li.breadcrumb-item', text: 'Employees').find('a').click
          should have_current_path(users_path)
        end
      end

      describe 'edit page' do
        before { visit edit_payment_path(payment) }

        it 'has the correct elements' do
          should have_selector('li.breadcrumb-item', text: 'Employees')
          should_not have_selector('li.breadcrumb-item', text: 'New User')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Profile')
          should have_selector('li.breadcrumb-item', text: 'Invoices')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Invoice')
          should have_selector('li.breadcrumb-item', text: 'Payments')
          should_not have_selector('li.breadcrumb-item', text: 'New Payment')
          should have_selector('li.breadcrumb-item.active', text: 'Edit Payment')
        end

        it 'redirects to payments index page properly' do
          find('li.breadcrumb-item', text: 'Payments').find('a').click
          should have_current_path(invoice_payments_path(invoice))
        end

        it 'redirects to invoices index page properly' do
          find('li.breadcrumb-item', text: 'Invoices').find('a').click
          should have_current_path(user_invoices_path(employee))
        end

        it 'redirects to user index page properly' do
          find('li.breadcrumb-item', text: 'Employees').find('a').click
          should have_current_path(users_path)
        end
      end
    end
  end

  describe 'manager' do
    let(:manager) { FactoryGirl.create(:manager) }
    let(:employee) { FactoryGirl.create(:employee) }
    let(:invoice) { FactoryGirl.create(:invoice, user: employee) }
    let(:payment) { FactoryGirl.create(:payment, invoice: invoice) }

    before { login manager }

    describe 'users' do
      describe 'index page' do
        it 'has the correct elements' do
          should have_selector('li.breadcrumb-item.active', text: 'Employees')
          should_not have_selector('li.breadcrumb-item', text: 'New User')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Profile')
          should_not have_selector('li.breadcrumb-item', text: 'Invoices')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Invoice')
          should_not have_selector('li.breadcrumb-item', text: 'Payments')
          should_not have_selector('li.breadcrumb-item', text: 'New Payment')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Payment')
        end
      end

      describe 'edit page' do
        before { visit edit_user_path(employee) }

        it 'has the correct elements' do
          should have_selector('li.breadcrumb-item', text: 'Employees')
          should_not have_selector('li.breadcrumb-item', text: 'New User')
          should have_selector('li.breadcrumb-item.active', text: 'Edit Profile')
          should_not have_selector('li.breadcrumb-item', text: 'Invoices')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Invoice')
          should_not have_selector('li.breadcrumb-item', text: 'Payments')
          should_not have_selector('li.breadcrumb-item', text: 'New Payment')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Payment')
        end

        it 'redirects to index page properly' do
          find('li.breadcrumb-item', text: 'Employees').find('a').click
          should have_current_path(users_path)
        end
      end
    end

    describe 'invoices' do
      describe 'index page' do
        before { visit user_invoices_path(employee) }

        it 'has the correct elements' do
          should have_selector('li.breadcrumb-item', text: 'Employees')
          should_not have_selector('li.breadcrumb-item', text: 'New User')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Profile')
          should have_selector('li.breadcrumb-item.active', text: 'Invoices')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Invoice')
          should_not have_selector('li.breadcrumb-item', text: 'Payments')
          should_not have_selector('li.breadcrumb-item', text: 'New Payment')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Payment')
        end

        it 'redirects to users index page properly' do
          find('li.breadcrumb-item', text: 'Employees').find('a').click
          should have_current_path(users_path)
        end
      end

      describe 'edit page' do
        before { visit edit_invoice_path(invoice) }

        it 'has the correct elements' do
          should have_selector('li.breadcrumb-item', text: 'Employees')
          should_not have_selector('li.breadcrumb-item', text: 'New User')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Profile')
          should have_selector('li.breadcrumb-item', text: 'Invoices')
          should have_selector('li.breadcrumb-item.active', text: 'Edit Invoice')
          should_not have_selector('li.breadcrumb-item', text: 'Payments')
          should_not have_selector('li.breadcrumb-item', text: 'New Payment')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Payment')
        end

        it 'redirects to invoices index page properly' do
          find('li.breadcrumb-item', text: 'Invoices').find('a').click
          should have_current_path(user_invoices_path(employee))
        end

        it 'redirects to user index page properly' do
          find('li.breadcrumb-item', text: 'Employees').find('a').click
          should have_current_path(users_path)
        end
      end
    end

    describe 'payments' do
      describe 'index page' do
        before { visit invoice_payments_path(invoice) }

        it 'has the correct elements' do
          should have_selector('li.breadcrumb-item', text: 'Employees')
          should_not have_selector('li.breadcrumb-item', text: 'New User')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Profile')
          should have_selector('li.breadcrumb-item', text: 'Invoices')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Invoice')
          should have_selector('li.breadcrumb-item.active', text: 'Payments')
          should_not have_selector('li.breadcrumb-item', text: 'New Payment')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Payment')
        end

        it 'redirects to invoices index page properly' do
          find('li.breadcrumb-item', text: 'Invoices').find('a').click
          should have_current_path(user_invoices_path(employee))
        end

        it 'redirects to user index page properly' do
          find('li.breadcrumb-item', text: 'Employees').find('a').click
          should have_current_path(users_path)
        end
      end

      describe 'new page' do
        before { visit new_invoice_payment_path(invoice) }

        it 'has the correct elements' do
          should have_selector('li.breadcrumb-item', text: 'Employees')
          should_not have_selector('li.breadcrumb-item', text: 'New User')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Profile')
          should have_selector('li.breadcrumb-item', text: 'Invoices')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Invoice')
          should have_selector('li.breadcrumb-item', text: 'Payments')
          should have_selector('li.breadcrumb-item.active', text: 'New Payment')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Payment')
        end

        it 'redirects to payments index page properly' do
          find('li.breadcrumb-item', text: 'Payments').find('a').click
          should have_current_path(invoice_payments_path(invoice))
        end

        it 'redirects to invoices index page properly' do
          find('li.breadcrumb-item', text: 'Invoices').find('a').click
          should have_current_path(user_invoices_path(employee))
        end

        it 'redirects to user index page properly' do
          find('li.breadcrumb-item', text: 'Employees').find('a').click
          should have_current_path(users_path)
        end
      end

      describe 'edit page' do
        before { visit edit_payment_path(payment) }

        it 'has the correct elements' do
          should have_selector('li.breadcrumb-item', text: 'Employees')
          should_not have_selector('li.breadcrumb-item', text: 'New User')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Profile')
          should have_selector('li.breadcrumb-item', text: 'Invoices')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Invoice')
          should have_selector('li.breadcrumb-item', text: 'Payments')
          should_not have_selector('li.breadcrumb-item', text: 'New Payment')
          should have_selector('li.breadcrumb-item.active', text: 'Edit Payment')
        end

        it 'redirects to payments index page properly' do
          find('li.breadcrumb-item', text: 'Payments').find('a').click
          should have_current_path(invoice_payments_path(invoice))
        end

        it 'redirects to invoices index page properly' do
          find('li.breadcrumb-item', text: 'Invoices').find('a').click
          should have_current_path(user_invoices_path(employee))
        end

        it 'redirects to user index page properly' do
          find('li.breadcrumb-item', text: 'Employees').find('a').click
          should have_current_path(users_path)
        end
      end
    end
  end

  describe 'employee' do
    let(:employee) { FactoryGirl.create(:employee) }
    let(:invoice) { FactoryGirl.create(:invoice, user: employee) }
    let(:payment) { FactoryGirl.create(:payment, invoice: invoice) }

    before { login employee }

    describe 'invoices' do
      describe 'index page' do
        it 'has the correct elements' do
          should_not have_selector('li.breadcrumb-item', text: 'Employees')
          should_not have_selector('li.breadcrumb-item', text: 'New User')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Profile')
          should have_selector('li.breadcrumb-item.active', text: 'Invoices')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Invoice')
          should_not have_selector('li.breadcrumb-item', text: 'Payments')
          should_not have_selector('li.breadcrumb-item', text: 'New Payment')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Payment')
        end
      end

      describe 'edit page' do
        before { visit edit_invoice_path(invoice) }

        it 'has the correct elements' do
          should_not have_selector('li.breadcrumb-item', text: 'Employees')
          should_not have_selector('li.breadcrumb-item', text: 'New User')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Profile')
          should have_selector('li.breadcrumb-item', text: 'Invoices')
          should have_selector('li.breadcrumb-item.active', text: 'Edit Invoice')
          should_not have_selector('li.breadcrumb-item', text: 'Payments')
          should_not have_selector('li.breadcrumb-item', text: 'New Payment')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Payment')
        end

        it 'redirects to index page properly' do
          find('li.breadcrumb-item', text: 'Invoices').find('a').click
          should have_current_path(user_invoices_path(employee))
        end
      end
    end

    describe 'payments' do
      describe 'index page' do
        before { visit invoice_payments_path(invoice) }

        it 'has the correct elements' do
          should_not have_selector('li.breadcrumb-item', text: 'Employees')
          should_not have_selector('li.breadcrumb-item', text: 'New User')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Profile')
          should have_selector('li.breadcrumb-item', text: 'Invoices')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Invoice')
          should have_selector('li.breadcrumb-item.active', text: 'Payments')
          should_not have_selector('li.breadcrumb-item', text: 'New Payment')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Payment')
        end

        it 'redirects to invoices index page properly' do
          find('li.breadcrumb-item', text: 'Invoices').find('a').click
          should have_current_path(user_invoices_path(employee))
        end
      end

      describe 'new page' do
        before { visit new_invoice_payment_path(invoice) }

        it 'has the correct elements' do
          should_not have_selector('li.breadcrumb-item', text: 'Employees')
          should_not have_selector('li.breadcrumb-item', text: 'New User')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Profile')
          should have_selector('li.breadcrumb-item', text: 'Invoices')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Invoice')
          should have_selector('li.breadcrumb-item', text: 'Payments')
          should have_selector('li.breadcrumb-item.active', text: 'New Payment')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Payment')
        end

        it 'redirects to payments index page properly' do
          find('li.breadcrumb-item', text: 'Payments').find('a').click
          should have_current_path(invoice_payments_path(invoice))
        end

        it 'redirects to invoice index page properly' do
          find('li.breadcrumb-item', text: 'Invoices').find('a').click
          should have_current_path(user_invoices_path(employee))
        end
      end

      describe 'edit page' do
        before { visit edit_payment_path(payment) }

        it 'has the correct elements' do
          should_not have_selector('li.breadcrumb-item', text: 'Employees')
          should_not have_selector('li.breadcrumb-item', text: 'New User')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Profile')
          should have_selector('li.breadcrumb-item', text: 'Invoices')
          should_not have_selector('li.breadcrumb-item', text: 'Edit Invoice')
          should have_selector('li.breadcrumb-item', text: 'Payments')
          should_not have_selector('li.breadcrumb-item', text: 'New Payment')
          should have_selector('li.breadcrumb-item.active', text: 'Edit Payment')
        end

        it 'redirects to payments index page properly' do
          find('li.breadcrumb-item', text: 'Payments').find('a').click
          should have_current_path(invoice_payments_path(invoice))
        end

        it 'redirects to invoice index page properly' do
          find('li.breadcrumb-item', text: 'Invoices').find('a').click
          should have_current_path(user_invoices_path(employee))
        end
      end
    end
  end
end