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

	def process_price
		strip_price = price.gsub(' ', '')
		prices = []
		prices << scan_million(strip_price)
		prices << scan_hundred_thousand(strip_price)
		prices << scan_ten_thousand(strip_price)
		prices.flatten!.each do |i|
			i.gsub!(',', '')
			i.gsub!('$', '')
		end
		set_prices(prices.map(&:to_i).sort)
	end

	def scan_ten_thousand(string)
		string.scan(/\$\d{2},\d{3}/)
	end

	def scan_hundred_thousand(string)
		string.scan(/\$\d{3},\d{3}/)
	end

	def scan_million(string)
		string.scan(/\$\d{1},\d{3},\d{3}/)
	end

	def set_prices(prices)
		if prices.size > 1
			update!(low_price: prices[0])
			update!(high_price: prices[1])
		end
	end
end