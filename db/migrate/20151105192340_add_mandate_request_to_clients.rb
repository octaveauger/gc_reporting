class AddMandateRequestToClients < ActiveRecord::Migration
  def change
  	add_column :clients, :locale, :string, index: true
  	add_column :clients, :mandate_request_description, :text
  	add_column :clients, :mandate_request_date, :datetime
  end
end
