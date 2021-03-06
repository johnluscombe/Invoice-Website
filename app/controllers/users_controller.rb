class UsersController < ApplicationController
  before_action :ensure_user_logged_in
  before_action :ensure_can_edit, only: [:edit, :update]
  before_action :ensure_manager, only: [:index]
  before_action :ensure_admin, only: [:new, :create, :destroy]

  def index
    @users = User.get_users(current_user)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if User.create_user(@user)
      redirect_to users_path
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
    if current_user.first_time
      flash.now[:error] = 'Please update your password'
    end
  end

  def update
    @user = User.find(params[:id])
    if @user.update_user(user_params, current_user?(@user))
      redirect
    else
      render 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy unless current_user?(@user)
    redirect_to users_path
  end

  private

  def user_params
    params.require(:user).permit(:fullname, :name, :email, :rate, :password, :password_confirmation, :profile,
                                 :first_time, invoices_attributes: [:id, :start_date, :end_date, :status])
  end

  def ensure_user_logged_in
    unless current_user
      redirect_to login_path(redirect: request.path)
    end
  end

  def ensure_can_edit
    @user = User.find(params[:id])
    unless current_user?(@user) or current_user.admin? or current_user.superior(@user)
      flash[:error] = 'You do not have permission to perform this action'
      redirect
    end
  rescue
    flash[:error] = 'Unable to find user'
    redirect
  end

  def ensure_manager
    unless current_user.manager?
      flash[:error] = 'You do not have permission to perform this action'
      redirect_to user_invoices_path(current_user)
    end
  end

  def ensure_admin
    unless current_user.admin?
      flash[:error] = 'You do not have permission to perform this action'
      redirect
    end
  end

  def redirect
    if current_user.manager?
      redirect_to users_path
    else
      redirect_to user_invoices_path(current_user)
    end
  end

  def redirect_path
    if current_user.manager?
      users_path
    else
      user_invoices_path(current_user)
    end
  end
  helper_method :redirect_path
end