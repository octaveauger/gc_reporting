namespace :data_migrations do
  desc "Create clients with source GoCardless for all existing customers"
  task create_clients: :environment do
    source_id = ClientSource.where(name: 'gocardless').first.id
    Customer.all.each do |customer|
      client = Client.create!(
        organisation_id: customer.organisation_id,
        fname: customer.given_name,
        lname: customer.family_name,
        company_name: customer.company_name,
        email: customer.email,
        client_source_id: source_id,
        source_client_id: nil
      )
      customer.update!(client_id: client.id)
    end
  end

end
