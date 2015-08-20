class AddAllFieldsToEvents < ActiveRecord::Migration
  def change
  	add_column :events, :resource_type, :string
  	add_column :events, :mandate_id, :string
  	add_column :events, :payout_id, :string
  	add_column :events, :refund_id, :string
  	add_column :events, :subscription_id, :string
  	add_column :events, :new_customer_bank_account_id, :string
  	add_column :events, :previous_customer_bank_account_id, :string
  	add_column :events, :parent_event_id, :string
  	
  	add_index :events, :resource_type
    add_index :events, :mandate_id
    add_index :events, :payout_id
    add_index :events, :refund_id
    add_index :events, :subscription_id
    add_index :events, :new_customer_bank_account_id
    add_index :events, :previous_customer_bank_account_id
    add_index :events, :parent_event_id
  end
end
