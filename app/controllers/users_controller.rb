class UsersController < ApplicationController
  before_action :ensure_user_logged_in, only: [:index, :destroy]
  #before_action :ensure_correct_user, only: [:edit, :update]
  before_action :ensure_admin, only: [:index, :destroy]

  def index
    @users = User.where(:admin => false)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.first_time = true
    if @user.save
      if current_user?(@user)
        flash[:success] = "Welcome to the site, #{@user.name}"
        redirect_to @user
      else
        flash[:success] = "User successfully created"
        redirect_to users_path
      end
    else
      flash.now[:danger] = "Unable to create new user"
      render 'new'
    end
  end

  def show
    @user = User.find(params[:id])
  rescue
    flash[:danger] = "Unable to find user"
    redirect_to users_path
  end

  def edit
    @user = User.find(params[:id])
    if !current_user?(@user) and !current_user.admin
      flash[:danger] = "Cannot edit other user's profiles"
      redirect_to users_path
    elsif current_user.first_time
      flash[:info] = "Please update your profile information"
    end
  rescue
    flash[:danger] = "Unable to find user"
    redirect_to users_path
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      if current_user?(@user)
        flash[:success] = "Your profile has been modified"
        redirect_to @user
      else
        flash[:success] = "User successfully updated"
        redirect_to users_path
      end
      @user.first_time = false
    else
      flash[:danger] = "Unable to update profile"
      render 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    flash[:success] = "#{@user.fullname} removed from the site"
    redirect_to users_path
  end

  private

  def user_params
    params.require(:user).permit(:fullname, :name, :email, :rate, :password, :password_confirmation,
                                 invoices_attributes: [:id, :start_date, :end_date, :status])
  end

  def ensure_user_logged_in
    unless current_user #If no user is logged in
      redirect_to login_path
    end
  end

  def ensure_correct_user
    @user = User.find(params[:id])
    unless current_user?(@user) #If the user does not match the one logged in
      flash[:danger] = "Cannot edit other user's profiles"
      redirect_to root_path
    end
  rescue #If the user cannot be found
    flash[:danger] = "Unable to find user"
    redirect_to users_path
  end

  def ensure_admin
    unless current_user and current_user.admin? #If the user is not admin
      flash[:danger] = 'Only admins allowed to delete user'
      redirect_to root_path
    end
  end
end
