class CreateOrganisationUpdates < ActiveRecord::Migration
  def change
    create_table :organisation_updates do |t|
      t.references :organisation, index: true
      t.string :category
      t.datetime :last_update

      t.timestamps
    end
    add_index :organisation_updates, [:organisation_id, :category], unique: true
  end
end
