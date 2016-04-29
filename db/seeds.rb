# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Initialising client sources
sources = ClientSource.all
sources = sources.map { |s| s.name }
sources_seed = [
	{ name: 'gocardless', display_name: 'GoCardless' },
	{ name: 'import', display_name: 'Import' }
]
sources_seed.each do |source|
	ClientSource.create(source) unless sources.include? source[:name]
end

# Initialising CRMs
crms = Crm.all
crms = crms.map { |s| s.name }
crms_seed = [
	{ name: 'sageone', display_name: 'SageOne' }
]
crms_seed.each do |crm|
	Crm.create(crm) unless crms.include? crm[:name]
end