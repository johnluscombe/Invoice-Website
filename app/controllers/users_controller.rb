class UsersController < ApplicationController
  before_action :ensure_user_logged_in, only: [:edit, :update, :destroy]
  before_action :ensure_correct_user, only: [:edit, :update]
  before_action :ensure_admin, only: [:destroy]

  def index
    @users = User.where(:admin => false)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      flash[:success] = "Welcome to the site, #{@user.name}"
      redirect_to @user
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
  rescue
    flash[:danger] = "Unable to find user"
    redirect_to users_path
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "Your profile has been modified"
      redirect_to @user
    else
      flash[:danger] = "Unable to update profile"
      render 'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    flash[:success] = "#{@user.name} removed from the site"
    redirect_to users_path
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation,
                                 invoices_attributes: [:id, :start_date, :end_date, :status])
  end

  def ensure_user_logged_in
    unless current_user #If no user is logged in
      flash[:warning] = "Not logged in"
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
    @user = User.find(params[:id])
    if (current_user.id == @user.id) #If admin tries to delete himself
      flash[:danger] = 'Cannot delete yourself'
      redirect_to root_path
    else
      unless current_user.admin? #If the user is not admin
        flash[:danger] = 'Only admins allowed to delete user'
        redirect_to root_path
      end
    end
  end
end
