class InvoicesController < ApplicationController
  before_action :ensure_user_logged_in
  before_action :ensure_correct_user, except: [:all, :submitted]

  def index
    @user = User.find(params[:user_id])
    @invoices = @user.invoices.ordered
    if @user.manager?
      flash[:error] = 'User does not get paid hourly'
      redirect_to users_path
    end
  end

  def all
    if ensure_admin
      @invoices = Invoice.all.ordered
      @all = true
      render 'index'
    end
  end

  def submitted
    if ensure_manager
      @invoices = Invoice.submitted.ordered
      @submitted = true
      render 'index'
    end
  end

  def new
    @user = User.find(params[:user_id])
    if @user.rate.nil?
      if @user.manager?
        flash[:error] = 'You have not set an hourly rate for this employee.'
      else
        flash[:error] = 'You have not been assigned an hourly rate. Please contact your manager.'
      end
      redirect_to user_invoices_path(@user)
    else
      @invoice = @user.invoices.build(:user_id => @user.id, :start_date => Date.today, :status => 'Started')
      if @invoice.save
        redirect_to user_invoices_path(@user)
      else
        render 'new'
      end
    end
  end

  def edit
    @invoice = Invoice.find(params[:id])
    @user = @invoice.user
  end

  def submit
    @invoice = Invoice.find(params[:invoice_id])
    @user = @invoice.user
    body = render_to_string partial: 'mailers/submit', locals: {submitter: current_user, invoice: @invoice}
    @invoice.submit(current_user, body)
    redirect_to :back
  rescue Exception => e
    puts e
    flash[:error] = 'Email failed to send'
    redirect_to :back
  end

  def reset
    @invoice = Invoice.find(params[:invoice_id])
    @user = @invoice.user
    @invoice.reset
    redirect_to :back
  end

  def pay
    @invoice = Invoice.find(params[:invoice_id])
    @user = @invoice.user
    body = render_to_string partial: 'mailers/pay', locals: {payer: current_user, invoice: @invoice}
    @invoice.pay(current_user, body)
    redirect_to :back
  rescue
    flash[:error] = 'Email failed to send'
    redirect_to :back
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
    if @all
      redirect_to all_invoices_path
    elsif @submitted
      redirect_to submitted_invoices_path
    else
      redirect_to user_invoices_path(@user)
    end
  end

  private

  def invoice_params
    params.require(:invoice).permit(:start_date, :end_date, :start_date_as_string, :end_date_as_string, :status, :hours,
                                    :net_pay, :rate, :check_no, :transfer_date, :transfer_date_as_string,
                                    payments_attributes: [:id, :date, :description, :hours])
  end

  def ensure_user_logged_in
    unless current_user
      redirect_to login_path(redirect: request.path)
    end
  end

  def ensure_correct_user
    if params[:user_id]
      @user = User.find(params[:user_id])
    else
      @invoice = Invoice.find(params[:id] || params[:invoice_id])
      @user = @invoice.user
    end
    unless current_user.manager? or current_user?(@user)
      flash[:error] = 'You do not have permission to perform this action'
      redirect
    end
  rescue
    flash[:error] = 'Unable to find invoice'
    redirect
  end

  def ensure_manager
    unless current_user.manager?
      flash[:error] = 'You do not have permission to perform this action'
      redirect_to user_invoices_path(current_user)
    end
    current_user.manager?
  end

  def ensure_admin
    unless current_user.admin?
      flash[:error] = 'You do not have permission to perform this action'
      redirect
    end
    current_user.admin?
  end

  def redirect
    if current_user.manager?
      redirect_to users_path
    else
      redirect_to user_invoices_path(current_user)
    end
  end
end
