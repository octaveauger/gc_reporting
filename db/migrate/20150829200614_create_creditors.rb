class CreateCreditors < ActiveRecord::Migration
  def change
    create_table :creditors do |t|
      t.references :organisation, index: true
      t.string :name
      t.string :address_line1
      t.string :address_line2
      t.string :address_line3
      t.string :city
      t.string :region
      t.string :postal_code
      t.string :country_code
      t.string :gc_id
      t.datetime :gc_created_at

      t.timestamps
    end
    add_index :creditors, :gc_id
  end
end
