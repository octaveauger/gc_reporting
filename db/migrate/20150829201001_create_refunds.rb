class CreateRefunds < ActiveRecord::Migration
  def change
    create_table :refunds do |t|
      t.references :payment, index: true
      t.integer :amount
      t.string :currency
      t.string :gc_id
      t.datetime :gc_created_at

      t.timestamps
    end
    add_index :refunds, :gc_id
  end
end
