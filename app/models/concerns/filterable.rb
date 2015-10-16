module Filterable
	extend ActiveSupport::Concern

	module ClassMethods
		def name_of_class
			ActiveModel::Naming.plural(self)
		end

		# Runs through all filtering parameters from form and trigger the right 'where' (from this module or the model)
		def filter(filtering_params)
			results = self.where(nil)
			filtering_params.each do |key, value|
				results = results.public_send(key, value) if value.present?
			end
			results
		end

		# Returns the dropdown options for usual time filters
		def time_filters
			[
				[I18n.t('filters.time.any'), 'any'],
				[I18n.t('filters.time.today'), 'today'],
				[I18n.t('filters.time.yesterday'), 'yesterday'],
				[I18n.t('filters.time.this_week'), 'this_week'],
				[I18n.t('filters.time.this_month'), 'this_month'],
				[I18n.t('filters.time.last_7_days'), 'last_7_days'],
				[I18n.t('filters.time.last_30_days'), 'last_30_days']
			]
		end

		# Filters results by usual time filters
		def time_filter(selection)
			case selection
			when 'any'
				self.all
			when 'today'
				self.where(name_of_class+'.gc_created_at >= ?', Date.today)
			when 'yesterday'
				self.where(name_of_classame+'.gc_created_at >= ?', Date.today - 1)
			when 'this_week'
				self.where(name_of_class+'.gc_created_at >= ?', Time.now.beginning_of_week)
			when 'this_month'
				self.where(name_of_class+'.gc_created_at >= ?', Time.now.beginning_of_month)
			when 'last_7_days'
				self.where(name_of_class+'.gc_created_at >= ?', Date.today - 7)
			when 'last_30_days'
				self.where(name_of_class+'.gc_created_at >= ?', Date.today - 30)
			else
				self.all
			end
		end
	end
end