class ChangeIdForFees < ActiveRecord::Migration
  def self.up
  	change_column :fees, :event_id, :string
  end

  def self.down
  	change_column :fees, :event_id, :integer
  end
end
