class AddClientIdToCustomers < ActiveRecord::Migration
  def change
  	add_column :customers, :client_id, :integer
  	add_index :customers, :client_id
  end
end
