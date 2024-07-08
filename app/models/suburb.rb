class Suburb < ApplicationRecord
	has_many :properties

	def setup_search(domain_suburb)
		scrape = Scraper.new
		property_data = scrape.process_request(domain_suburb)
		property_data.each do |prop|
			properties.create!(
				link: prop[0],
				address: prop[1]['address'],
				beds: prop[1]['beds'],
				baths: prop[1]['baths'],
				cars: prop[1]['cars'],
				land: prop[1]['land'],
				price: prop[1]['price']
			)
		end
	end

end