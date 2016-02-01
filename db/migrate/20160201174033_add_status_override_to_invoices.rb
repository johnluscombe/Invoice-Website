class AddStatusOverrideToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :status_override, :boolean
  end
end
