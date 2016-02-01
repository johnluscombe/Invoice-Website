class SubmitEmail < ApplicationMailer
  default from: "notification@luscombeandassociates.com"

  def send_submit_email(user, invoice)
    @user = user
    @invoice = invoice
    mail( :to => "johnluscombe@yahoo.com",
          :subject => 'You have submitted your invoice' )
  end
end