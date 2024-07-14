class Suburb < ApplicationRecord
	has_many :properties

	def setup_search(domain_tag)
		scrape = Scraper.new
		browser = scrape.get_browser
		property_data = scrape.process_request(domain_tag, browser)
		properties.build_from_page_data(property_data, browser)
		browser.quit
	end
end