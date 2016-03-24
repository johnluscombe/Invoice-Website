class UsersController < ApplicationController
  before_action :ensure_user_logged_in
  #before_action :ensure_correct_user
  before_action :ensure_admin, only: [:index, :new, :create, :destroy]

  def index
    if current_user.master
      @users = User.all
    else
      @users = User.where(:admin => false)
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.password_digest==nil
      @user.password = "password"
      @user.password_confirmation = "password"
    end
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
        if @user.admin
          redirect_to users_path
        else
          redirect_to user_invoices_path(@user)
        end
      else
        flash[:success] = "User successfully updated"
        redirect_to users_path
      end
      @user.first_time = false
      @user.save
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
    unless current_user
      redirect_to login_path
    end
  end

  def ensure_correct_user
    @user = User.find(params[:user_id])
    unless current_user?(@user)
      if current_user.admin
        flash[:danger] = "There has a been a problem loading the page, we're sorry for the inconvenience"
        redirect_to users_path
      else
        flash[:danger] = "There has a been a problem loading the page, please contact your administrator"
        redirect_to user_invoices_path(current_user)
      end
    end
  end

  def ensure_admin
    unless current_user.admin
      flash[:danger] = "There has a been a problem loading the page, please contact your administrator"
      redirect_to user_invoices_path(current_user)
    end
  end
end
