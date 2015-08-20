class AddGcCreatedAtToEvents < ActiveRecord::Migration
  def change
  	add_column :payment_events, :gc_created_at, :datetime
  end
end
