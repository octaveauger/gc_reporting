class Client < ActiveRecord::Base
  include Tokenable
  include Filterable

  belongs_to :client_source
  belongs_to :organisation
  has_many :customers
  has_many :customer_bank_accounts, through: :customers
  has_many :mandates, through: :customer_bank_accounts
  has_many :payments, through: :mandates
  has_many :events, through: :payments
  has_many :refunds, through: :payments
  has_many :subscriptions, through: :mandates

  validates :client_source_id, presence: true
  validates :source_created_at, presence: true
  validates :email, format: /.+@.+\..+/i, allow_blank: true

  def full_name
  	self.fname.to_s + ' ' + self.lname.to_s
  end

  def display_name
  	if self.fname.blank? and self.lname.blank?
  		self.company_name
  	else
	  	company_name = (self.company_name.blank? ? '' : '(' + self.company_name.to_s + ')')
	  	self.fname.to_s + ' ' + self.lname.to_s + company_name
    end
  end

  # TODOS:
  # Encoding issues: breaks if non UTF8 (i.e accents)
  # Check that errors work and also add begin / rescue with error notification
  # Translated headers
  def self.import_csv(file, organisation)
    options = { row_sep: :auto, file_encoding: 'utf-8', :key_mapping => {:unwanted_row => nil, :fname => :fname}}
    results = []
    source_id = ClientSource.find_by(name: 'import').id
    SmarterCSV.process(file, options) do |imported_client|
      imported_client
      client = organisation.clients.new(imported_client.first)
      client.assign_attributes(source_created_at: Time.now) if client.source_created_at.nil?
      client.assign_attributes(client_source_id: source_id)
      if client.save
        results.push(client: client)
      else
        results.push(client: client, errors: client.errors)
      end
    end
    results
  end
end
