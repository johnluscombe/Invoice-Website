class PayMailer < ApplicationMailer
  def pay_email(from_user, to_user, invoice)
    @from_user = from_user
    @to_user = to_user
    @invoice = invoice

    if @from_user.fullname.nil? or @from_user.fullname == ''
      @from_name = @from_user.name
    else
      @from_name = @from_user.fullname
    end

    if @to_user.fullname.nil? or @to_user.fullname == ''
      @to_name = @to_user.name
    else
      @to_name = @to_user.fullname
    end

    if @invoice.net_pay.nil?
      mail(from: "#{ @from_name } <luscombeandassociatesinvoice@gmail.com>", to: @to_user.email, subject: @from_name + ' has paid your invoice for $' + @invoice.get_net_pay)
    else
      mail(from: "#{ @from_name } <luscombeandassociatesinvoice@gmail.com>", to: @to_user.email, subject: @from_name + ' has paid your invoice for $' + sprintf('%.2f', @invoice.net_pay))
    end
  end
end