class PaymentsController < ApplicationController
  before_action :ensure_user_logged_in
  before_action :ensure_correct_user

  def index
    @invoice = Invoice.find(params[:invoice_id])
    @payments = @invoice.payments.all.order(:date)
    @user = @invoice.user
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
    if @payment.save
      redirect_to invoice_payments_path(:invoice_id => @invoice.id)
    else
      render 'new'
    end
  end

  def update
    @payment = Payment.find(params[:id])
    @invoice = @payment.invoice
    if @payment.update(payment_params)
      redirect_to invoice_payments_path(:invoice_id => @invoice.id)
    else
      render 'edit'
    end
  end

  def destroy
    @payment = Payment.find(params[:id])
    @invoice = @payment.invoice
    @payment.destroy
    redirect_to invoice_payments_path(@invoice)
  end

  private

  def payment_params
    params.require(:payment).permit(:date, :date_as_string, :description, :hours, :daily_rate)
  end

  def ensure_user_logged_in
    unless current_user
      redirect_to login_path(redirect: request.path)
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
    unless current_user.manager? or current_user?(@user)
      flash[:error] = 'You do not have permission to perform this action'
      redirect
    end
  rescue
    flash[:error] = 'Unable to find payment'
    redirect
  end

  def redirect
    if current_user.manager?
      redirect_to users_path
    else
      redirect_to user_invoices_path(current_user)
    end
  end
end