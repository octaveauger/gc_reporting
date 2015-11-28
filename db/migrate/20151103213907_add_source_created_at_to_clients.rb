class AddSourceCreatedAtToClients < ActiveRecord::Migration
  def change
    add_column :clients, :source_created_at, :datetime
  end
end
