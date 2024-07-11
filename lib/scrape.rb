require "ferrum"

class Scraper
	
	def item(number)
		return "li[#{number}]"
	end
	
	def get_beds(element)
		if element.at_xpath(@bed_loc)
			element.at_xpath(@bed_loc).text
		end
	end
	
	def get_baths(element)
		if element.at_xpath(@bath_loc)
			element.at_xpath(@bath_loc).text
		end
	end
	
	def get_cars(element)
		if element.at_xpath(@car_loc)
			element.at_xpath(@car_loc).text
		end
	end
	
	def get_land(element)
		if element.at_xpath(@land_loc)
			element.at_xpath(@land_loc).text
			
		end
	end
	
	def get_address(element)
		if element.at_xpath(@address_loc)
			element.at_xpath(@address_loc).text
		end
	end
	
	def get_price(element)
		if element.at_xpath(@price_loc)
			element.at_xpath(@price_loc).text
		end
	end
	
	def get_listing_links(page)
		@list = "/html/body/div[1]/div/div[2]/div[4]/div[2]/div[1]/div[2]/ul/"
		@link_loc = "div/div[2]/div/a"
		@bed_loc = "div/div[2]/div/div[2]/div[1]/div/span[1]/span"
		@bath_loc = "div/div[2]/div/div[2]/div[1]/div/span[2]/span"
		@car_loc = "div/div[2]/div/div[2]/div[1]/div/span[3]/span"
		@land_loc = "div/div[2]/div/div[2]/div[1]/div/span[4]/span"
		@address_loc = "div/div[2]/div/a/h2"
		@price_loc = "div/div[2]/div/div[1]"
		properties = {}
		
		@browser.go_to(page)
		sleep 2
		@page_finished = false
		@c = 1
		until @page_finished do 
			puts "page #{@counter} grabbing #{@c}"
			retries = 0
			begin
				if @browser.at_xpath("/html/body/div[1]/div/div[2]/div[4]/div[2]/div[1]/div[2]/div[2]/h3")
					if @browser.at_xpath("/html/body/div[1]/div/div[2]/div[4]/div[2]/div[1]/div[2]/div[2]/h3").text == "No exact matches"
						@finished = true
						break
					end
				end
				if @browser.at_xpath("#{@list}#{item(@c)}")
					li = @browser.at_xpath("#{@list}#{item(@c)}")
					if li && li.at_xpath(@link_loc)
						properties[li.at_xpath(@link_loc).description["attributes"][1]] = {}
						properties[li.at_xpath(@link_loc).description["attributes"][1]]["address"] = get_address(li)
						properties[li.at_xpath(@link_loc).description["attributes"][1]]["price"] = get_price(li)
						properties[li.at_xpath(@link_loc).description["attributes"][1]]["beds"] = get_beds(li)
						properties[li.at_xpath(@link_loc).description["attributes"][1]]["baths"] = get_baths(li)
						properties[li.at_xpath(@link_loc).description["attributes"][1]]["cars"] = get_cars(li)
						properties[li.at_xpath(@link_loc).description["attributes"][1]]["land"] = get_land(li)
					end
				else
					@page_finished = true
					break
				end
			rescue Exception => e
				puts e
				retries += 1
				sleep(1)
				retry if (retries <= 5)
				raise "Couldn't do it: #{e}"
			end
			@c += 1
		end
		return properties
	end
	
	def build_url(suburb)
		base = "https://www.domain.com.au/sale/#{suburb}/?excludeunderoffer=1&ssubs=0&page=#{@counter}"
		# 'excludeunderoffer=1&ssubs=0&'
		return base
	end
	
	def process_request(domain_suburb)
		@props = {}
		@browser = Ferrum::Browser.new
		@counter = 1
		@finished = false
		until @finished do
			a = get_listing_links(build_url(domain_suburb))
			
			if a
				@props = @props.merge(a)
			end
			@counter += 1
			@finished = true #remove to debug
		end
		@browser.quit
		return @props
	end

	def property_description(link)
		retry_count = 0
		browser = Ferrum::Browser.new
		begin
			browser.go_to(link)
			sleep 1
			browser.at_css('div.css-14y7q63 > button').focus.click
			description = browser.at_css('#__next > div > div.css-1ktrj7 > div > div.css-4bd6g2 > div > div > div.css-bq4jj8').text
			browser.quit
		rescue
			retry_count += 1
			puts "Unable to get description #{link}, retrying #{retry_count} time"
			retry if retry_count < 5
		end
		
		return description  
	end
end