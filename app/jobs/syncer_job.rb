class SyncerJob 
  include SuckerPunch::Job
  workers 2
    
  def perform(organisation)
    ActiveRecord::Base.connection_pool.with_connection do
    	client = GocardlessPro.new(organisation)
  		client.sync_data
  	end
  end
end
