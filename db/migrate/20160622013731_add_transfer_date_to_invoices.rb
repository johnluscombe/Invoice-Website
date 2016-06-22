class AddTransferDateToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :transfer_date, :date
  end
end
