class Event < ActiveRecord::Base
  include Filterable

  belongs_to :payment, primary_key: 'gc_id', foreign_key: 'payment_id'
  belongs_to :refund, primary_key: 'gc_id', foreign_key: 'refund_id'
  has_one :fee, primary_key: 'gc_id', foreign_key: 'event_id'

  # TODO: shit code - to clean up once fees API launched
  # Returns a summary of volume + fees per currency for all payouts mentioned in payout_ids
  def self.statistics_payouts(payout_ids)
	payout_ids = [payout_ids] if !payout_ids.respond_to?('each')
	volume = { 'gbp' => 0, 'eur' => 0, 'sek' => 0 }
	fees = { 'gbp' => 0, 'eur' => 0, 'sek' => 0 }
	payout_ids.each do |payout_id|
		payout = Payout.find_by(gc_id: payout_id)
		volume[payout.currency.downcase] += payout.amount.to_i
		fees[payout.currency.downcase] += payout.sum_fees.to_i
	end
	{
		'gbp' => { volume: volume['gbp'], fees: fees['gbp'] },
		'eur' => { volume: volume['eur'], fees: fees['eur'] },
		'sek' => { volume: volume['sek'], fees: fees['sek'] }
	}
  end
end
