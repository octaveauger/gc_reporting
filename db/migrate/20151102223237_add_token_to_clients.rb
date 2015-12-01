class AddTokenToClients < ActiveRecord::Migration
  def change
  	add_column :clients, :token, :string
  	add_index :clients, :token
  end
end
