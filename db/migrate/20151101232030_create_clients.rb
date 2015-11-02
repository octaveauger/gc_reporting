class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.references :organisation, index: true
      t.string :fname
      t.string :lname
      t.string :company_name
      t.string :email
      t.references :client_source, index: true
      t.string :source_client_id

      t.timestamps
    end
    add_index :clients, :source_client_id
    add_index :clients, :email
  end
end
