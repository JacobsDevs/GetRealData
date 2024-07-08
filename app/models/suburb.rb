class Suburb < ApplicationRecord
	has_many :properties

	def setup_search(domain_suburb)
		scrape = Scraper.new
		property_data = scrape.process_request(domain_suburb)
		properties.build_from_page_data(property_data)
	end

end