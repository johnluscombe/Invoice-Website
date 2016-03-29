class InvoicesController < ApplicationController
  before_action :ensure_user_logged_in
  before_action :ensure_correct_user

  def index
    if params.has_key?(:all)
      ensure_master
      @invoices = Invoice.all
    elsif params.has_key?(:pending_only)
      ensure_admin
      @invoices = Invoice.where(:status => "Pending")
    else
      @user = User.find(params[:user_id])
      if @user.admin
        flash[:warning] = "User does not get paid hourly"
        redirect_to users_path
      end
      @invoices = @user.invoices.all.order(:start_date).reverse_order
    end
  rescue
    redirect
  end

  def show
    redirect
  end

  def new
    @user = User.find(params[:user_id])
    if @user.rate == nil
      if @user.admin
        flash[:danger] = "You have not set an hourly rate for this employee."
      else
        flash[:danger] = "You have not been assigned an hourly rate. Please contact your manager."
      end
      redirect_to user_invoices_path(@user)
    else
      @invoice = @user.invoices.build(:user_id => @user.id, :start_date => Date.today, :status => "Started")
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
    if params.has_key?(:submit)
      if @invoice.end_date == nil
        @invoice.update(:end_date => Date.today, :status => "Pending")
      else
        @invoice.update(:status => "Pending")
      end
      #SubmitEmail.send_submit_email(@user, @invoice).deliver
      if params.has_key?(:from_payments)
        redirect_to invoice_payments_path(@invoice)
      else
        if params.has_key?(:from_pending)
          redirect_to invoices_path(:pending_only => true)
        else
          redirect_to user_invoices_path(@user)
        end
      end
    elsif params.has_key?(:reset)
      @invoice.update(:status => "In Progress")
      if params.has_key?(:from_payments)
        redirect_to invoice_payments_path(@invoice)
      else
        if params.has_key?(:from_pending)
          redirect_to invoices_path(:pending_only => true)
        else
          redirect_to user_invoices_path(@user)
        end
      end
    elsif current_user.admin and params.has_key?(:approve)
      @invoice.update(:status => "Paid")
      if params.has_key?(:from_pending)
        redirect_to invoices_path(:pending_only => true)
      else
        redirect_to user_invoices_path(@user)
      end
    end
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
    params.require(:invoice).permit(:start_date, :end_date, :status, :hours, :net_pay, :rate, :check_no,
                                    payments_attributes: [:id, :date, :description, :hours])
  end

  def ensure_user_logged_in
    unless current_user
      redirect_to login_path
    end
  end

  def ensure_correct_user
    if params[:user_id]
      @user = User.find(params[:user_id])
    else
      @invoice = Invoice.find(params[:id])
      @user = @invoice.user
    end
    unless current_user.admin or current_user?(@user)
      flash[:danger] = "You do not have permission to view this page. Please contact your manager."
      redirect
    end
  rescue
    redirect
  end

  def redirect
    if current_user.admin
      redirect_to users_path
    else
      redirect_to user_invoices_path(current_user)
    end
  end
end
