require_relative '../../../rails_helper'
require_relative '../../../support/login'

describe 'Manager Users Permissions' do
  subject { page }

  describe 'manager' do
    let(:admin) { FactoryGirl.create(:admin) }
    let(:manager) { FactoryGirl.create(:manager) }
    let(:other_manager) { FactoryGirl.create(:manager) }
    let(:employee) { FactoryGirl.create(:employee) }

    before { login manager }

    describe 'users index' do
      before { visit users_path }

      it 'should load the page without error' do
        should have_content 'Employees'
        should_not have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
      end
    end

    describe 'user new' do
      before { visit new_user_path }

      it 'should give a permissions error' do
        should_not have_content 'New user'
        should have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
      end
    end

    describe 'user edit for self' do
      before { visit edit_user_path(manager) }

      it 'should load the page without error' do
        should have_content 'Edit profile'
        should_not have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
      end
    end

    describe 'user edit for admin' do
      before { visit edit_user_path(admin) }

      it 'should give a permissions error' do
        should_not have_content 'Edit profile'
        should have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
      end
    end

    describe 'user edit for manager' do
      before { visit edit_user_path(other_manager) }

      it 'should give a permissions error' do
        should_not have_content 'Edit profile'
        should have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
      end
    end

    describe 'user edit for employee' do
      before { visit edit_user_path(employee) }

      it 'should load the page without error' do
        should have_content 'Edit profile'
        should_not have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
      end
    end

    describe 'user delete for self' do
      before { page.driver.submit :delete, user_path(manager), {} }

      it 'should give a permissions error' do
        should have_content 'Employees'
        should have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
        should_not have_content 'You cannot delete yourself'
      end
    end

    describe 'user delete for admin' do
      before { page.driver.submit :delete, user_path(admin), {} }

      it 'should give a permissions error' do
        should have_content 'Employees'
        should have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
        should_not have_content 'You cannot delete yourself'
      end
    end

    describe 'user delete for manager' do
      before { page.driver.submit :delete, user_path(other_manager), {} }

      it 'should give a permissions error' do
        should have_content 'Employees'
        should have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
        should_not have_content 'You cannot delete yourself'
      end
    end

    describe 'user delete for employee' do
      before { page.driver.submit :delete, user_path(employee), {} }

      it 'should give a permissions error' do
        should have_content 'Employees'
        should have_content 'You do not have permission to perform this action.'
        should_not have_content 'Unable'
        should_not have_content 'You cannot delete yourself'
      end
    end
  end
end