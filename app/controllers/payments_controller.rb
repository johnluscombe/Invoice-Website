class PaymentsController < ApplicationController
  #before_action :ensure_user_logged_in, only: [:edit, :update, :destroy]
  #before_action :ensure_correct_user, only: [:edit, :update]
  #before_action :ensure_admin, only: [:destroy]

  def index
    @invoice = Invoice.find(params[:invoice_id])
    @payments = @invoice.payments.all.order(:date)
  end

  def new
    @invoice = Invoice.find(params[:invoice_id])
    @payment = @invoice.payments.build
    @user = @invoice.user
  end

  def edit
    @payment = Payment.find(params[:id])
    @invoice = @payment.invoice
    @user = @invoice.user
  end

  def create
    @invoice = Invoice.find(params[:invoice_id])
    @payment = @invoice.payments.build(payment_params)
    @user = @invoice.user

    if @payment.save
      @invoice.status = "In Progress"
      @invoice.save
      redirect_to invoice_payments_path(:invoice_id => @invoice.id)
    else
      render 'new'
    end
  end

  def show
    @invoice = Invoice.find(params[:invoice_id])
    @payment = @invoice.payments.build(payment_params)
    @user = @invoice.user
  rescue
    flash[:danger] = "Unable to find user"
    redirect_to users_path
  end

  def update
    @payment = Payment.find(params[:id])
    @invoice = @payment.invoice
    @user = @invoice.user

    if @payment.update(payment_params)
      redirect_to invoice_payments_path(:invoice_id => @invoice.id)
    else
      render 'edit'
    end
  end

  def destroy
    @payment = Payment.find(params[:id])
    @invoice = @payment.invoice
    @user = @invoice.user
    @payment.destroy

    redirect_to user_invoices_path(@user)
  end

  private

  def payment_params
    params.require(:payment).permit(:date, :description, :hours)
  end

  def ensure_user_logged_in
    unless current_user #If no user is logged in
      flash[:warning] = "Not logged in"
      redirect_to login_path
    end
  end

  def ensure_correct_user
    @invoice = Invoice.find(params[:invoice_id])
    @user = @invoice.user
    unless current_user?(@user) #If the user does not match the one logged in
      flash[:danger] = "Cannot edit other user's profiles"
      redirect_to root_path
    end
  rescue #If the user cannot be found
    flash[:danger] = "Unable to find user"
    redirect_to users_path
  end

  def ensure_admin
    @invoice = Invoice.find(params[:invoice_id])
    @user = @invoice.user
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
