class CreateClientSources < ActiveRecord::Migration
  def change
    create_table :client_sources do |t|
      t.string :name

      t.timestamps
    end
    add_index :client_sources, :name
  end
end
