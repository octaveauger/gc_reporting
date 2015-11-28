namespace :data_migrations do
  desc "Create clients with source GoCardless for all existing customers (until 20151102224245)"
  task create_clients: :environment do
    source_id = ClientSource.where(name: 'gocardless').first.id
    Customer.all.each do |customer|
      client = Client.create!(
        organisation_id: 6,#customer.organisation_id,
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

  desc "Add gc_created_at as source_created_at to all Clients(until 20151103213907)"
  task add_source_created_at_to_clients: :environment do
    Client.all.each do |client|
      client.update!(source_created_at: client.customers.first.gc_created_at)
    end
  end

end
