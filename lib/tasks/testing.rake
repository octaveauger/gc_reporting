namespace :testing do

  desc "Empty the whole database apart from Organisations"
  task empty_db: :environment do
  	Customer.destroy_all
  	CustomerBankAccount.destroy_all
  	Mandate.destroy_all
  	Payment.destroy_all
  	Event.destroy_all
  	OrganisationUpdate.destroy_all
  end
end