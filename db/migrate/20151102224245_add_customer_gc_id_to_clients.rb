class AddCustomerGcIdToClients < ActiveRecord::Migration
  def change
  	add_column :clients, :customer_gc_id, :string
  	add_index :clients, :customer_gc_id
  end
end
