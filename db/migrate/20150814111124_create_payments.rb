class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.references :mandate, index: true
      t.date :charge_date
      t.integer :amount
      t.string :description
      t.string :currency
      t.string :status
      t.string :reference
      t.integer :amount_refunded
      t.string :gc_id, index: true
      t.datetime :gc_created_at

      t.timestamps
    end
  end
end
