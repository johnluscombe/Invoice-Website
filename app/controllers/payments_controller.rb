class PaymentsController < ApplicationController
  before_action :ensure_user_logged_in
  before_action :ensure_correct_user

  def index
    @invoice = Invoice.find(params[:invoice_id])
    @payments = @invoice.payments.all.order(:date)
    @user = @invoice.user
  end

  def show
    if current_user.admin
      redirect_to users_path
    else
      redirect_to user_invoices_path(current_user)
    end
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
      @invoice.status = 'In Progress'
      @invoice.save
      redirect_to invoice_payments_path(:invoice_id => @invoice.id)
    else
      render 'new'
    end
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

    redirect_to invoice_payments_path(@invoice)
  end

  private

  def payment_params
    params.require(:payment).permit(:date, :description, :hours, :daily_rate)
  end

  def ensure_user_logged_in
    unless current_user
      redirect_to login_path
    end
  end

  def ensure_correct_user
    if params[:invoice_id]
      @invoice = Invoice.find(params[:invoice_id])
      @user = @invoice.user
    else
      @payment = Payment.find(params[:id])
      @invoice = @payment.invoice
      @user = @invoice.user
    end
    unless current_user.admin or current_user?(@user)
      flash[:danger] = 'You do not have permission to view this page. Please contact your manager.'
      redirect
    end
  end

  def redirect
    if current_user.admin
      redirect_to users_path
    else
      redirect_to user_invoices_path(current_user)
    end
  end
end
