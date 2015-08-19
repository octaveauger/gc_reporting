class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.references :organisation, index: true
      t.string :address_line_1
      t.string :address_line_2
      t.string :address_line_3
      t.string :city
      t.string :company_name
      t.string :country_code
      t.string :email
      t.string :given_name
      t.string :family_name
      t.string :postal_code
      t.string :region
      t.string :gc_id, index: true
      t.datetime :gc_created_at

      t.timestamps
    end
  end
end
