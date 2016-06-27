require_relative '../../../rails_helper'
require_relative '../../../support/login'

describe 'Employee Users Permissions' do
  subject { page }

  describe 'employee' do
    let(:admin) { FactoryGirl.create(:admin) }
    let(:manager) { FactoryGirl.create(:manager) }
    let(:employee) { FactoryGirl.create(:employee) }
    let(:other_employee) { FactoryGirl.create(:employee) }

    before { login employee }

    describe 'users index' do
      before { visit users_path }

      it 'should give a permissions error' do
        should have_current_path(user_invoices_path(employee))
        should have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
      end
    end

    describe 'new user' do
      before { visit new_user_path }

      it 'should give a permissions error' do
        should have_current_path(user_invoices_path(employee))
        should have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
      end
    end

    describe 'edit self' do
      before { visit edit_user_path(employee) }

      it 'should load the page without error' do
        should have_current_path(edit_user_path(employee))
        should_not have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
      end
    end

    describe 'edit admin' do
      before { visit edit_user_path(admin) }

      it 'should give a permissions error' do
        should have_current_path(user_invoices_path(employee))
        should have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
      end
    end

    describe 'edit manager' do
      before { visit edit_user_path(manager) }

      it 'should give a permissions error' do
        should have_current_path(user_invoices_path(employee))
        should have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
      end
    end

    describe 'edit another employee' do
      before { visit edit_user_path(other_employee) }

      it 'should give a permissions error' do
        should have_current_path(user_invoices_path(employee))
        should have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
      end
    end

    describe 'delete self' do
      before { page.driver.submit :delete, user_path(employee), {} }

      it 'should give a permissions error' do
        should have_current_path(user_invoices_path(employee))
        should have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
      end
    end

    describe 'delete admin' do
      before { page.driver.submit :delete, user_path(admin), {} }

      it 'should give a permissions error' do
        should have_current_path(user_invoices_path(employee))
        should have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
        should_not have_content 'You cannot delete yourself'
      end
    end

    describe 'delete manager' do
      before { page.driver.submit :delete, user_path(manager), {} }

      it 'should give a permissions error' do
        should have_current_path(user_invoices_path(employee))
        should have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
        should_not have_content 'You cannot delete yourself'
      end
    end

    describe 'delete another employee' do
      before { page.driver.submit :delete, user_path(other_employee), {} }

      it 'should give a permissions error' do
        should have_current_path(user_invoices_path(employee))
        should have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
        should_not have_content 'You cannot delete yourself'
      end
    end
  end
end