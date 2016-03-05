class AddCheckNoToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :check_no, :integer
  end
end
