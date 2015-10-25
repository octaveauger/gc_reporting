class ExpandOrganisation < ActiveRecord::Migration
  def change
  	add_column :organisations, :fname, :string
  	add_column :organisations, :lname, :string
  	add_column :organisations, :email, :string
  	add_column :organisations, :company_name, :string
  end
end
