class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.date :start_date
      t.date :end_date
      t.string :status
      #t.references :user_id, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
