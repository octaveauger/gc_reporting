class RenamingCustomerFields < ActiveRecord::Migration
  def change
  	rename_column :customers, :address_line_1, :address_line1
  	rename_column :customers, :address_line_2, :address_line2
  	rename_column :customers, :address_line_3, :address_line3
  end
end
