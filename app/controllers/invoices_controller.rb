class InvoicesController < ApplicationController
  before_action :ensure_user_logged_in, only: [:edit, :update, :destroy]
  before_action :ensure_correct_user, only: [:edit, :update]
  before_action :ensure_admin, only: [:destroy]

  def index
    @user = User.find(params[:user_id])
    @invoices = @user.invoices.all
  end

  def new
    @user = User.find(params[:user_id])
    @invoice = @user.invoices.build
  end

  def edit
    @invoice = Invoice.find(params[:id])
    @user = @invoice.user
  end

  def create
    @user = User.find(params[:user_id])
    @invoice = @user.invoices.build(invoice_params)
    if @invoice.save
      redirect_to user_invoices_path(@user)
    else
      render 'new'
    end
  end

  def show
    @user = User.find(params[:user_id])
    @invoice = @user.invoices.build(invoice_params)
  rescue
    flash[:danger] = "Unable to find user"
    redirect_to users_path
  end

  def update
    @invoice = Invoice.find(params[:id])
    @user = @invoice.user

    if @invoice.update(invoice_params)
      redirect_to user_invoices_path(@user)
    else
      render 'edit'
    end
  end

  def destroy
    @invoice = Invoice.find(params[:id])
    @user = @invoice.user
    @invoice.destroy

    redirect_to user_invoices_path(@user)
  end

  private

  def invoice_params
    params.require(:invoice).permit(:start_date, :end_date, :status,
                                    payments_attributes: [:id, :date, :description, :hours])
  end

  def ensure_user_logged_in
    unless current_user #If no user is logged in
      flash[:warning] = "Not logged in"
      redirect_to login_path
    end
  end

  def ensure_correct_user
    @user = User.find(params[:user_id])
    unless current_user?(@user) #If the user does not match the one logged in
      flash[:danger] = "Cannot edit other user's profiles"
      redirect_to root_path
    end
  rescue #If the user cannot be found
    flash[:danger] = "Unable to find user"
    redirect_to users_path
  end

  def ensure_admin
    @user = User.find(params[:user_id])
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
