class InvoicesController < ApplicationController
  before_action :ensure_user_logged_in
  before_action :ensure_correct_user, only: [:index]
  #before_action :ensure_admin, only: [:index]

  def index
    @user = User.find(params[:user_id])
    @invoices = @user.invoices.all
  end

  def new
    @user = User.find(params[:user_id])
    @invoice = @user.invoices.build(:user_id => @user.id, :start_date => "2016-01-01", :status => "Started")
    if @invoice.save
      redirect_to user_invoices_path(@user)
    else
      render 'new'
    end
  end

  def edit
    @invoice = Invoice.find(params[:id])
    @user = @invoice.user
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
    unless current_user
      redirect_to login_path
    end
  end

  def ensure_correct_user
    @user = User.find(params[:user_id])
    unless current_user.admin or current_user?(@user)
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
