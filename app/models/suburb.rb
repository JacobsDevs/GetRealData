class Suburb < ApplicationRecord
	has_many :properties

	def setup_search(domain_tag)
		scrape = Scraper.new
		property_data = scrape.process_request(domain_tag)
		properties.build_from_page_data(property_data)
	end
end