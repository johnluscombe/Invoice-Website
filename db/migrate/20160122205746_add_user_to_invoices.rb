class AddUserToInvoices < ActiveRecord::Migration
  def change
    add_reference :invoices, :user, index: true, foreign_key: true
  end
end
