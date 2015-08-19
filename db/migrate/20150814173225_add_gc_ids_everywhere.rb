class AddGcIdsEverywhere < ActiveRecord::Migration
  def change
  	add_index :organisations, :gc_id
  	add_index :customers, :gc_id
  	add_index :customer_bank_accounts, :gc_id
  	add_index :mandates, :gc_id
  	add_index :payments, :gc_id
  	add_index :payment_events, :gc_id
  end
end
