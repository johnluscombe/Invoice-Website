class AddHoursAndNetPayToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :hours, :float
    add_column :invoices, :net_pay, :float
  end
end
