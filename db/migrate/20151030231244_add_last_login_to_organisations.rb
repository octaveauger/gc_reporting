class AddLastLoginToOrganisations < ActiveRecord::Migration
  def change
  	add_column :organisations, :last_login, :datetime
  end
end
