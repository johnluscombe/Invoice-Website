class RemoveUserIdFromInvoices < ActiveRecord::Migration
  def change
    remove_reference :invoices, :user_id, index: true, foreign_key: true
  end
end
