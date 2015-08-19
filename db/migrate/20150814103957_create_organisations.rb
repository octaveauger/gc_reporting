class CreateOrganisations < ActiveRecord::Migration
  def change
    create_table :organisations do |t|
      t.string :access_token
      t.string :gc_id, index: true

      t.timestamps
    end
  end
end