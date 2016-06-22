class LoginsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(name: params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      if user.first_time
        redirect_to edit_user_path(user)
      else
        if user.profile >= 2
          redirect_to users_path
        else
          redirect_to user_invoices_path(user)
        end
      end
    else
      flash.now[:danger] = 'Invalid username or password'
      render 'new'
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to users_path
  end
end
