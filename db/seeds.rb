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