class Payment < ActiveRecord::Base
  belongs_to :mandate, primary_key: 'gc_id', foreign_key: 'mandate_id'
  delegate :customer_bank_account, to: :mandate
  delegate :customer, to: :customer_bank_account
  has_many :events, primary_key: 'gc_id', foreign_key: 'payment_id'
  has_many :refunds, primary_key: 'gc_id', foreign_key: 'payment_id'

  def failure_cause
    self.status == 'failed' ? self.events.where(action: 'failed').first.cause : ''
  end
end
