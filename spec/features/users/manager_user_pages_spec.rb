require_relative '../../rails_helper'
require_relative '../../support/login'

describe 'Manager User Pages' do
  subject { page }

  describe 'manager' do
    let(:manager) { FactoryGirl.create(:manager) }

    before do
      10.times { FactoryGirl.create(:employee) }
      10.times { FactoryGirl.create(:manager) }
      10.times { FactoryGirl.create(:admin) }
      login manager
    end

    it 'should have 31 users' do
      expect(User.count).to eq(31)
    end

    describe 'list users' do
      it 'should show only employees' do
        User.all.each do |user|
          should have_link('VIEW INVOICES')
          should have_link('EDIT')
          should_not have_link('DELETE')

          if user.manager?
            should_not have_selector('tr', text: user.email)
          else
            should_not have_selector('tr', text: user.id.to_s + ' User')
            should have_selector('tr', text: user.fullname + ' ' + user.email)
            should have_selector('tr', text: '$ 10.00 -')
          end
        end
      end
    end

    describe 'new user' do
      before { visit new_user_path }

      it 'redirects to the users page' do
        should have_current_path(users_path)
      end

      it 'produces an error message' do
        should have_content('You do not have permission to perform this action')
      end
    end

    describe 'editing users' do
      let(:submit) { 'UPDATE USER PROFILE' }

      describe 'own profile' do
        let!(:original_name) { manager.name }

        before { visit edit_user_path(manager) }

        it 'has the correct fields' do
          should have_field('user_fullname', with: manager.fullname)
          should have_field('user_name', with: manager.name)
          should have_field('user_email', with: manager.email)
          should have_field('user_password')
        end

        describe 'with invalid information' do
          before do
            fill_in 'user_fullname', with: ''
            fill_in 'user_name', with: ''
            fill_in 'user_email', with: ''
          end

          describe 'does not change data' do
            before { click_button submit }

            specify { expect(manager.reload.name).not_to eq('') }
            specify { expect(manager.reload.name).to eq(original_name) }
          end

          it 'does not add a new user to the system' do
            expect { click_button submit }.not_to change(User, :count)
          end

          it 'produces an error message' do
            click_button submit
            should have_content("Name can't be blank")
          end
        end

        describe 'with valid information' do
          before do
            fill_in 'user_fullname', with: 'New Name'
            fill_in 'user_name', with: 'newname'
            fill_in 'user_email', with: 'new.name@example.com'
          end

          describe 'changes the data' do
            before { click_button submit }

            specify { expect(manager.reload.fullname).to eq('New Name') }
            specify { expect(manager.reload.name).to eq('newname') }
            specify { expect(manager.reload.email).to eq('new.name@example.com') }
          end

          it 'redirects back to users page and shows user' do
            click_button submit
            should have_current_path(users_path)
            should_not have_selector('tr', text: manager.fullname)
          end

          it 'does not add a new user to the system' do
            expect { click_button submit }.not_to change(User, :count)
          end
        end
      end

      describe 'employee profile' do
        let(:employee) { FactoryGirl.create(:employee) }
        let!(:original_name) { employee.name }

        before { visit edit_user_path(employee) }

        it 'has the correct fields' do
          should have_field('user_fullname', with: employee.fullname)
          should have_field('user_name', with: employee.name)
          should have_field('user_email', with: employee.email)
          should have_field('user_rate')
        end

        describe 'with invalid information' do
          before do
            fill_in 'user_fullname', with: ''
            fill_in 'user_name', with: ''
            fill_in 'user_email', with: ''
          end

          describe 'does not change data' do
            before { click_button submit }

            specify { expect(employee.reload.name).not_to eq('') }
            specify { expect(employee.reload.name).to eq(original_name) }
          end

          it 'does not add a new user to the system' do
            expect { click_button submit }.not_to change(User, :count)
          end

          it 'produces an error message' do
            click_button submit
            should have_content("Name can't be blank")
          end
        end

        describe 'non-existant' do
          before { visit edit_user_path(-1) }

          it 'redirects back to users page' do
            should have_current_path(users_path)
          end

          it { should have_content('Unable') }
        end

        describe 'with valid information' do
          before do
            fill_in 'user_fullname', with: 'New Name'
            fill_in 'user_name', with: 'newname'
            fill_in 'user_email', with: 'new.name@example.com'
            fill_in 'user_rate', with: 11
          end

          describe 'changes the data' do
            before { click_button submit }

            specify { expect(employee.reload.fullname).to eq('New Name') }
            specify { expect(employee.reload.name).to eq('newname') }
            specify { expect(employee.reload.email).to eq('new.name@example.com') }
            specify { expect(employee.reload.rate).to eq(11) }
          end

          it 'redirects back to users page and shows user' do
            click_button submit
            should have_current_path(users_path)
            should have_selector('tr', text: 'New Name new.name@example.com $ 11.00 -')
          end

          it 'does not add a new user to the system' do
            expect { click_button submit }.not_to change(User, :count)
          end
        end
      end

      describe 'manager profile' do
        let(:new_manager) { FactoryGirl.create(:manager) }

        before { visit edit_user_path(new_manager) }

        it 'redirects to the users page' do
          should have_current_path(users_path)
        end

        it 'produces an error message' do
          should have_content('You do not have permission to perform this action')
        end
      end

      describe 'admin profile' do
        let(:admin) { FactoryGirl.create(:admin) }

        before { visit edit_user_path(admin) }

        it 'redirects to the users page' do
          should have_current_path(users_path)
        end

        it 'produces an error message' do
          should have_content('You do not have permission to perform this action')
        end
      end
    end

    describe 'delete users' do
      let!(:employee) { FactoryGirl.create(:employee) }

      before { visit users_path }

      it { should_not have_link('Delete User', href: user_path(employee)) }
    end
  end
end