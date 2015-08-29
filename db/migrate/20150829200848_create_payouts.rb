class CreatePayouts < ActiveRecord::Migration
  def change
    create_table :payouts do |t|
      t.references :creditor, index: true
      t.integer :amount
      t.string :currency
      t.string :reference
      t.string :status
      t.string :gc_id
      t.datetime :gc_created_at

      t.timestamps
    end
    add_index :payouts, :gc_id
  end
end
