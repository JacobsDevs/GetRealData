class Property < ApplicationRecord
	belongs_to :suburb

	def self.build_from_page_data(data)
		data.each do |prop|
			self.create!(
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

	def get_description_from_link
		scrape = Scraper.new
		update!(description: scrape.property_description(link))
	end
end