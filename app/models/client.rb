class Client < ActiveRecord::Base
  include Tokenable
  include Filterable

  attr_accessor :request_mandate # boolean to check if we should send a mandate request in a form

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
  validate :email_present_if_mandate_request

  before_save :update_mandate_request_date, if: :request_mandate
  after_save :email_mandate_request, if: :request_mandate

  def email_present_if_mandate_request
    if self.email.blank? and self.request_mandate and self.request_mandate != '0'
      errors.add(:email, :email_required_for_mandate_request)
    end
  end

  def full_name
  	self.fname.to_s + ' ' + self.lname.to_s
  end

  def display_name
  	if self.fname.blank? and self.lname.blank?
  		self.company_name
  	else
	  	company_name = (self.company_name.blank? ? '' : ' (' + self.company_name.to_s + ')')
	  	self.fname.to_s + ' ' + self.lname.to_s + company_name
    end
  end

  # Returns the dropdown options for valid mandate filters
  def self.valid_mandate_filters
    [
      [I18n.t('filters.valid_mandate.any'), 'any'],
      [I18n.t('filters.valid_mandate.valid'), 'valid'],
      [I18n.t('filters.valid_mandate.pending'), 'pending'],
      [I18n.t('filters.valid_mandate.none'), 'none']
    ]
  end

  # Filters results by valid mandate filters
  def self.valid_mandate_filter(selection)
    case selection
    when 'any'
      self.all
    when 'valid'
      self.where('mandates.status = ? OR mandates.status = ? OR mandates.status = ?', 'pending_submission', 'submitted', 'active')
    when 'pending'
      self.where('mandate_request_date IS NOT ?', nil).where.not('mandates.status = ? OR mandates.status = ? OR mandates.status = ?', 'pending_submission', 'submitted', 'active')
    when 'none'
      self.where('mandate_request_date IS ?', nil).where.not('mandates.status = ? OR mandates.status = ? OR mandates.status = ?', 'pending_submission', 'submitted', 'active')
    end
  end

  # Returns the mandate state (valid / pending / none) as well as possible mandate request actions
  def mandate_actions
    if self.mandates.can_take_payment.any?
      { state: 'valid', actions: [] }
    elsif self.email.blank?
      { state: 'none', actions: [] }
    else
      if self.mandate_request_date.nil?
        { state: 'none', actions: ['request'] }
      elsif self.mandate_request_date < 2.days.ago
        { state: 'pending', actions: ['remind'] }
      else
        { state: 'pending', actions: [] }
      end
    end
  end

  def update_mandate_request_date
    self.mandate_request_date = Time.now if self.request_mandate != '0'
  end

  def email_mandate_request
    MailerClientJob.new.async.perform(self, 'mandate_request') if self.request_mandate != '0'
  end
end
