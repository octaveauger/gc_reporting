class AddCreditorToMandates < ActiveRecord::Migration
  def change
  	add_column :mandates, :creditor_id, :string
  	add_index :mandates, :creditor_id
  end
end
