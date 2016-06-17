require_relative '../rails_helper'
require_relative '../support/login'

describe 'Employee User Pages' do
  subject { page }

  describe 'employee' do
    let(:employee) { FactoryGirl.create(:employee) }

    before do
      10.times { FactoryGirl.create(:employee) }
      10.times { FactoryGirl.create(:manager) }
      10.times { FactoryGirl.create(:admin) }
      login employee
    end

    it 'should have 25 users' do
      expect(User.count).to eq(31)
    end

    describe 'list users' do
      before { visit new_user_path }

      it 'redirects to the invoices page' do
        should have_content('Invoices')
      end

      it 'produces an error message' do
        should have_content('You do not have permission to perform this action. Please contact your administrator.')
      end
    end

    describe 'new user' do
      before { visit new_user_path }

      it 'redirects to the invoices page' do
        should have_content('Invoices')
      end

      it 'produces an error message' do
        should have_content('You do not have permission to perform this action. Please contact your administrator.')
      end
    end

    describe 'editing users' do
      let(:submit) { 'UPDATE USER PROFILE' }

      describe 'own profile' do
        let!(:original_name) { employee.name }

        before do
          visit edit_user_path(employee)
        end

        it 'has the correct fields' do
          should have_field('user_fullname', with: employee.fullname)
          should have_field('user_name', with: employee.name)
          should have_field('user_email', with: employee.email)
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

        describe 'with valid information' do
          before do
            fill_in 'user_fullname', with: 'New Name'
            fill_in 'user_name', with: 'newname'
            fill_in 'user_email', with: 'new.name@example.com'
          end

          describe 'changes the data' do
            before { click_button submit }

            specify { expect(employee.reload.fullname).to eq('New Name') }
            specify { expect(employee.reload.name).to eq('newname') }
            specify { expect(employee.reload.email).to eq('new.name@example.com') }
          end

          it 'redirects back to invoices page' do
            click_button submit
            should have_content 'Invoices'
            should_not have_selector('tr', text: employee.fullname)
          end

          it 'does not add a new user to the system' do
            expect { click_button submit }.not_to change(User, :count)
          end
        end
      end

      describe 'employee profile' do
        let(:new_employee) { FactoryGirl.create(:employee) }
        let!(:original_name) { new_employee.name }

        before { visit edit_user_path(new_employee) }

        it 'redirects to the invoices page' do
          should have_content('Invoices')
        end

        it 'produces an error message' do
          should have_content('You do not have permission to perform this action. Please contact your manager.')
        end
      end

      describe 'manager profile' do
        let(:new_manager) { FactoryGirl.create(:manager) }

        before do
          visit edit_user_path(new_manager)
        end

        it 'redirects to the invoices page' do
          should have_content('Invoices')
        end

        it 'produces an error message' do
          should have_content('You do not have permission to perform this action. Please contact your manager.')
        end
      end

      describe 'admin profile' do
        let(:admin) { FactoryGirl.create(:admin) }

        before do
          visit edit_user_path(admin)
        end

        it 'redirects to the invoices page' do
          should have_content('Invoices')
        end

        it 'produces an error message' do
          should have_content('You do not have permission to perform this action. Please contact your manager.')
        end
      end
    end
  end
end