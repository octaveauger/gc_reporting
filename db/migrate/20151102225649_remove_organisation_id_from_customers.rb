class RemoveOrganisationIdFromCustomers < ActiveRecord::Migration
  def change
    remove_column :customers, :organisation_id, :integer
  end
end
