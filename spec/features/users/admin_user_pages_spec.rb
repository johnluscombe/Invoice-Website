require_relative '../../rails_helper'
require_relative '../../support/login'

describe 'Admin User Pages' do
  subject { page }

  describe 'admin' do
    let(:admin) { FactoryGirl.create(:admin) }

    before do
      10.times { FactoryGirl.create(:employee) }
      10.times { FactoryGirl.create(:manager) }
      10.times { FactoryGirl.create(:admin) }
      login admin
    end

    it 'should have 31 users' do
      expect(User.count).to eq(31)
    end

    describe 'list users' do
      it 'should show all users' do
        User.all.each do |user|
          should have_selector('tr', text: user.id.to_s + ' ' + user.fullname + ' ' + user.name + ' ' + user.email)
          should have_link('VIEW INVOICES')
          should have_link('EDIT')
          should have_link('DELETE')

          if user.admin?
            should have_selector('tr', text: 'N/A N/A Administrator No')
          elsif user.manager?
            should have_selector('tr', text: 'N/A N/A Manager No')
          else
            should have_selector('tr', text: '$ 10.00 - Employee No')
          end
        end
      end
    end

    describe 'new user' do
      let(:submit) { 'CREATE NEW USER' }
      let(:cancel) { 'CANCEL' }

      before { visit new_user_path }

      describe 'with invalid information' do
        it 'does not add the user to the system' do
          expect { click_button submit }.not_to change(User, :count)
        end

        it 'produces an error message' do
          click_button submit
          should have_content("Name can't be blank")
        end
      end

      describe 'with valid information' do
        describe 'adding employee' do
          before do
            fill_in 'user_fullname', with: 'New Name'
            fill_in 'user_name', with: 'newname'
            fill_in 'user_email', with: 'new.name@example.com'
            fill_in 'Rate', with: 10
          end

          it 'allows the user to fill in the fields' do
            click_button submit
          end

          it 'does add the user to the system' do
            expect { click_button submit }.to change(User, :count).by(1)
          end

          it 'redirects to users page and shows new user' do
            click_button submit
            should have_current_path(users_path)
            should have_selector('tr', text: 'New Name newname new.name@example.com $ 10.00 - Employee Yes')
          end
        end

        describe 'adding manager' do
          before do
            fill_in 'user_fullname', with: 'New Name'
            fill_in 'user_name', with: 'newname'
            fill_in 'user_email', with: 'new.name@example.com'
            select 'Manager', from: 'user_profile'
          end

          it 'allows the user to fill in the fields' do
            click_button submit
          end

          it 'does add the user to the system' do
            expect { click_button submit }.to change(User, :count).by(1)
          end

          it 'redirects to users page and shows new user' do
            click_button submit
            should have_current_path(users_path)
            should have_selector('tr', text: 'New Name newname new.name@example.com N/A N/A Manager Yes')
          end
        end

        describe 'adding admin' do
          before do
            fill_in 'user_fullname', with: 'New Name'
            fill_in 'user_name', with: 'newname'
            fill_in 'user_email', with: 'new.name@example.com'
            select 'Administrator', from: 'user_profile'
          end

          it 'allows the user to fill in the fields' do
            click_button submit
          end

          it 'does add the user to the system' do
            expect { click_button submit }.to change(User, :count).by(1)
          end

          it 'redirects to users page and shows new user' do
            click_button submit
            should have_current_path(users_path)
            should have_selector('tr', text: 'New Name newname new.name@example.com N/A N/A Administrator Yes')
          end
        end
      end

      describe 'clicking cancel' do
        it 'does not add the user to the system' do
          expect { click_link cancel }.not_to change(User, :count)
        end

        it 'redirects to users page' do
          click_link cancel
          should have_current_path(users_path)
        end
      end
    end

    describe 'editing users' do
      let(:submit) { 'UPDATE USER PROFILE' }
      let(:cancel) { 'CANCEL' }

      describe 'own profile' do
        let!(:original_name) { admin.name }

        before { visit edit_user_path(admin) }

        it 'has the correct fields' do
          should have_field('user_fullname', with: admin.fullname)
          should have_field('user_name', with: admin.name)
          should have_field('user_email', with: admin.email)
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

            specify { expect(admin.reload.name).not_to eq('') }
            specify { expect(admin.reload.name).to eq(original_name) }
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

            specify { expect(admin.reload.fullname).to eq('New Name') }
            specify { expect(admin.reload.name).to eq('newname') }
            specify { expect(admin.reload.email).to eq('new.name@example.com') }
          end

          it 'redirects back to users page and shows user' do
            click_button submit
            should have_current_path(users_path)
            should have_selector('tr', text: 'New Name newname new.name@example.com N/A N/A Administrator No')
          end

          it 'does not add a new user to the system' do
            expect { click_button submit }.not_to change(User, :count)
          end
        end

        describe 'clicking cancel' do
          it 'does not add the user to the system' do
            expect { click_link cancel }.not_to change(User, :count)
          end

          it 'redirects to users page' do
            click_link cancel
            should have_current_path(users_path)
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
          should have_field('user_profile')
          should have_field('user_first_time')
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
            should have_content 'Employees'
            should have_selector('tr', text: 'New Name newname new.name@example.com $ 11.00 - Employee No')
          end

          it 'does not add a new user to the system' do
            expect { click_button submit }.not_to change(User, :count)
          end

          describe 'upgrade to manager' do
            before { select 'Manager', from: 'user_profile' }

            it 'redirects back to users page and shows user' do
              click_button submit
              should have_current_path(users_path)
              should have_selector('tr', text: 'New Name newname new.name@example.com N/A N/A Manager No')
            end
          end

          describe 'upgrade to admin' do
            before { select 'Administrator', from: 'user_profile' }

            it 'redirects back to users page and shows user' do
              click_button submit
              should have_current_path(users_path)
              should have_selector('tr', text: 'New Name newname new.name@example.com N/A N/A Administrator No')
            end
          end
        end
      end

      describe 'manager profile' do
        let(:manager) { FactoryGirl.create(:manager) }
        let!(:original_name) { manager.name }

        before { visit edit_user_path(manager) }

        it 'has the correct fields' do
          should have_field('user_fullname', with: manager.fullname)
          should have_field('user_name', with: manager.name)
          should have_field('user_email', with: manager.email)
          should have_field('user_profile')
          should have_field('user_first_time')
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
            should have_selector('tr', text: 'New Name newname new.name@example.com N/A N/A Manager No')
          end

          it 'does not add a new user to the system' do
            expect { click_button submit }.not_to change(User, :count)
          end

          describe 'downgrade to employee' do
            before { select 'Employee', from: 'user_profile' }

            it 'redirects back to users page and shows user' do
              click_button submit
              should have_current_path(users_path)
              should have_selector('tr', text: 'New Name newname new.name@example.com - - Employee No')
            end
          end

          describe 'upgrade to admin' do
            before { select 'Administrator', from: 'user_profile' }

            it 'redirects back to users page and shows user' do
              click_button submit
              should have_current_path(users_path)
              should have_selector('tr', text: 'New Name newname new.name@example.com N/A N/A Administrator No')
            end
          end
        end
      end

      describe 'admin profile' do
        let(:new_admin) { FactoryGirl.create(:admin) }
        let!(:original_name) { new_admin.name }

        before { visit edit_user_path(new_admin) }

        it 'has the correct fields' do
          should have_field('user_fullname', with: new_admin.fullname)
          should have_field('user_name', with: new_admin.name)
          should have_field('user_email', with: new_admin.email)
          should have_field('user_profile')
          should have_field('user_first_time')
        end

        describe 'with valid information' do
          before do
            fill_in 'user_fullname', with: 'New Name'
            fill_in 'user_name', with: 'newname'
            fill_in 'user_email', with: 'new.name@example.com'
          end

          describe 'changes the data' do
            before { click_button submit }

            specify { expect(new_admin.reload.fullname).to eq('New Name') }
            specify { expect(new_admin.reload.name).to eq('newname') }
            specify { expect(new_admin.reload.email).to eq('new.name@example.com') }
          end

          it 'redirects back to users page and shows user' do
            click_button submit
            should have_current_path(users_path)
            should have_selector('tr', text: 'New Name newname new.name@example.com N/A N/A Administrator No')
          end

          it 'does not add a new user to the system' do
            expect { click_button submit }.not_to change(User, :count)
          end

          describe 'downgrade to employee' do
            before { select 'Employee', from: 'user_profile' }

            it 'redirects back to users page and shows user' do
              click_button submit
              should have_current_path(users_path)
              should have_selector('tr', text: 'New Name newname new.name@example.com - - Employee No')
            end
          end

          describe 'downgrade to manager' do
            before { select 'Manager', from: 'user_profile' }

            it 'redirects back to users page and shows user' do
              click_button submit
              should have_current_path(users_path)
              should have_selector('tr', text: 'New Name newname new.name@example.com N/A N/A Manager No')
            end
          end
        end
      end
    end

    describe 'delete users' do
      let!(:employee) { FactoryGirl.create(:employee) }
      let!(:manager) { FactoryGirl.create(:manager) }

      before { visit users_path }

      it { should have_link('DELETE', href: user_path(employee)) }

      it 'redirects properly' do
        click_link('DELETE', href: user_path(employee))
        should have_current_path(users_path)
      end

      it 'removes an employee from the system' do
        expect do
          click_link('DELETE', href: user_path(employee))
        end.to change(User, :count).by(-1)
      end

      it 'removes a manager from the system' do
        expect do
          click_link('DELETE', href: user_path(manager))
        end.to change(User, :count).by(-1)
      end
    end
  end
end