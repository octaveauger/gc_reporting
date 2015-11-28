class AddDisplayNameToClientSources < ActiveRecord::Migration
  def change
  	add_column :client_sources, :display_name, :string
  end
end
