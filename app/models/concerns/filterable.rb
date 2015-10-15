module Filterable
	extend ActiveSupport::Concern

	module ClassMethods
		# Returns the dropdown options for usual time filters
		def time_filters
			[
				['Any', 'any'],
				['Today', 'today'],
				['Yesterday', 'yesterday'],
				['This week', 'this_week'],
				['This month', 'this_month'],
				['Last 7 days', 'last_7_days'],
				['Last 30 days', 'last_30_days']
			]
		end

		# Filters results by usual time filters
		def time_filter(selection)
			name = ActiveModel::Naming.plural(self)
			case selection
			when 'any'
				self.all
			when 'today'
				self.where(name+'.gc_created_at >= ?', Date.today)
			when 'yesterday'
				self.where(name+'.gc_created_at >= ?', Date.today - 1)
			when 'this_week'
				self.where(name+'.gc_created_at >= ?', Time.now.beginning_of_week)
			when 'this_month'
				self.where(name+'.gc_created_at >= ?', Time.now.beginning_of_month)
			when 'last_7_days'
				self.where(name+'.gc_created_at >= ?', Date.today - 7)
			when 'last_30_days'
				self.where(name+'.gc_created_at >= ?', Date.today - 30)
			else
				self.all
			end
		end

		def filter(filtering_params)
			results = self.where(nil)
			filtering_params.each do |key, value|
				results = results.public_send(key, value) if value.present?
			end
			results
		end
	end
end