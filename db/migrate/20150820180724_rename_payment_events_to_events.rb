class RenamePaymentEventsToEvents < ActiveRecord::Migration
  def self.up
  	rename_table :payment_events, :events
  end

  def self.down
  	rename_table :events, :payment_events
  end
end
