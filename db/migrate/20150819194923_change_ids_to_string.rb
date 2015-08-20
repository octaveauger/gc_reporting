class ChangeIdsToString < ActiveRecord::Migration
  def self.up
  	change_column :customer_bank_accounts, :customer_id, :string
  	change_column :mandates, :customer_bank_account_id, :string
  	change_column :payment_events, :payment_id, :string
  	change_column :payments, :mandate_id, :string
  end

  def self.down
  	change_column :customer_bank_accounts, :customer_id, :integer
  	change_column :mandates, :customer_bank_account_id, :integer
  	change_column :payment_events, :payment_id, :integer
  	change_column :payments, :mandate_id, :integer
  end
end
