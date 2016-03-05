class AddRateToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :rate, :float
  end
end
