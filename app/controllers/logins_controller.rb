class LoginsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(name: params[:username])
    if user && user.authenticate(params[:password])
      if !user.first_time
        flash[:success] = 'Logged in'
      end
      session[:user_id] = user.id
      if user.first_time
        redirect_to edit_user_path(user)
      else
        redirect_to users_path
      end
    else
      flash.now[:danger] = 'Invalid username or password'
      render 'new'
    end
  end

  def destroy
    flash[:info] = 'Logged out'
    session[:user_id] = nil
    redirect_to users_path
  end
end
