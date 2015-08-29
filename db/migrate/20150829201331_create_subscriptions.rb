class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.references :mandate, index: true
      t.integer :amount
      t.string :currency
      t.string :status
      t.string :name
      t.datetime :start_date
      t.datetime :end_date
      t.integer :interval
      t.string :interval_unit
      t.integer :day_of_month
      t.string :month
      t.string :payment_reference
      t.string :gc_id
      t.datetime :gc_created_at

      t.timestamps
    end
    add_index :subscriptions, :gc_id
  end
end
