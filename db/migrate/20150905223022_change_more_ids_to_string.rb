class ChangeMoreIdsToString < ActiveRecord::Migration
  def self.up
  	change_column :payouts, :creditor_id, :string
  	change_column :refunds, :payment_id, :string
  	change_column :subscriptions, :mandate_id, :string
  end

  def self.down
  	change_column :payouts, :creditor_id, :integer
  	change_column :refunds, :payment_id, :integer
  	change_column :subscriptions, :mandate_id, :integer
  end
end
