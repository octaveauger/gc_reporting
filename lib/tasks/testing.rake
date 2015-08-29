namespace :testing do

  desc "Empty the whole database apart from Organisations"
  task empty_db: :environment do
  	Creditor.destroy_all
  	Customer.destroy_all
  	CustomerBankAccount.destroy_all
  	Mandate.destroy_all
  	Payment.destroy_all
  	Payout.destroy_all
  	Refund.destroy_all
  	Subscription.destroy_all
  	Event.destroy_all
  	OrganisationUpdate.destroy_all
  end
end