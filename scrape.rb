require "ferrum"

@list = "/html/body/div[1]/div/div[2]/div[4]/div[2]/div[1]/div[2]/ul/"
@link_loc = "div/div[2]/div/a"
@bed_loc = "div/div[2]/div/div[2]/div[1]/div/span[1]/span"
@bath_loc = "div/div[2]/div/div[2]/div[1]/div/span[2]/span"
@car_loc = "div/div[2]/div/div[2]/div[1]/div/span[3]/span"
@land_loc = "div/div[2]/div/div[2]/div[1]/div/span[4]/span"

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

def get_listing_links(page)
	properties = {}
	
	@browser.go_to(page)
	
	23.times do |c|
		li = @browser.at_xpath("#{@list + item(c + 1)}")
		if li.at_xpath(@link_loc)
			properties[li.at_xpath(@link_loc).description["attributes"][1]] = {}
			properties[li.at_xpath(@link_loc).description["attributes"][1]]["beds"] = get_beds(li)
			properties[li.at_xpath(@link_loc).description["attributes"][1]]["baths"] = get_baths(li)
			properties[li.at_xpath(@link_loc).description["attributes"][1]]["cars"] = get_cars(li)
			properties[li.at_xpath(@link_loc).description["attributes"][1]]["land"] = get_land(li)
		end
	end
	return properties
end

def test_page(page)
	@browser = Ferrum::Browser.new
	
	@browser.go_to(page)
end

@props = {}
@browser = Ferrum::Browser.new
23.times do |c|
	a = get_listing_links("https://www.domain.com.au/sale/rosebud-vic-3939/?excludeunderoffer=1&page=#{c + 1}")
	@props = @props.merge(a)
end
@browser.quit
require 'pry'; binding.pry