class LoginsController < ApplicationController
  def new
    if current_user
      redirect_to_home_for(current_user)
    end
  end

  def create
    user = User.find_by(name: params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      if user.first_time
        redirect_to edit_user_path(user)
      else
        redirect_to_home_for(user)
      end
    else
      flash.now[:invalid] = 'Invalid username or password'
      render 'new'
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to login_path
  end

  private

  def redirect_to_home_for(user)
    if params[:redirect]
      redirect_to params[:redirect]
    elsif user.manager?
      redirect_to users_path
    else
      redirect_to user_invoices_path(user)
    end
  end
end
