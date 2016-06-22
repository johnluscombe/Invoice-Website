class UsersController < ApplicationController
  before_action :ensure_user_logged_in
  before_action :ensure_correct_user, only: [:edit, :update]
  before_action :ensure_admin, only: [:index]
  before_action :ensure_master, only: [:new, :create, :destroy]

  def index
    @users = User.get_users(current_user)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.password_digest==nil
      @user.password = 'password'
      @user.password_confirmation = 'password'
    end
    if @user.save
      redirect_to users_path
    else
      flash.now[:danger] = 'Unable to create new user'
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
    if !current_user?(@user) and current_user.profile == 1
      flash[:danger] = "Cannot edit other user's profiles"
      redirect_to users_path
    elsif current_user.first_time
      flash.now[:info] = 'Please update your profile information'
    end
  # rescue
  #   flash[:danger] = 'Unable to find user'
  #   redirect_to users_path
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      if current_user?(@user)
        redirect
      else
        redirect_to users_path
      end
      if current_user?(@user)
        @user.first_time = false
      end
      @user.save
    else
      flash.now[:danger] = 'Unable to update profile'
      render 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_path
  end

  private

  def user_params
    params.require(:user).permit(:fullname, :name, :email, :rate, :password, :password_confirmation, :profile,
                                 :first_time, invoices_attributes: [:id, :start_date, :end_date, :status])
  end

  def ensure_user_logged_in
    unless current_user
      redirect_to login_path
    end
  end

  def ensure_correct_user
    @user = User.find(params[:id])
    #If the queried user does not match AND the current user is not an admin OR
    #If the queried user does not match AND the current user is not a master AND the queried user is an admin
    #Give an error
    if (!current_user?(@user) and current_user.profile == 1) or (!current_user?(@user) and current_user.profile < 3 and @user.profile >= 2)
      if current_user.profile >= 2
        flash[:danger] = 'You do not have permission to perform this action. Please contact your administrator.'
      else
        flash[:danger] = 'You do not have permission to perform this action. Please contact your manager.'
      end
      redirect
    end
  rescue
    flash[:danger] = 'Unable to find user'
    redirect
  end

  def ensure_admin
    unless current_user.profile >= 2
      flash[:danger] = 'You do not have permission to perform this action. Please contact your manager.'
      redirect_to user_invoices_path(current_user)
    end
  end

  def ensure_master
    unless current_user.profile == 3
      flash[:danger] = 'You do not have permission to perform this action. Please contact your administrator.'
      redirect
    end
  end

  def redirect
    if current_user.profile >= 2
      redirect_to users_path
    else
      redirect_to user_invoices_path(current_user)
    end
  end
end