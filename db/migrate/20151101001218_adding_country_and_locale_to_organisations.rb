class AddingCountryAndLocaleToOrganisations < ActiveRecord::Migration
  def change
  	add_column :organisations, :country, :string
  	add_column :organisations, :locale, :string
  end
end
