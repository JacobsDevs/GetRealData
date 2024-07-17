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
			if @browser.at_xpath("/html/body/div[1]/div/div[2]/div[4]/div[2]/div[1]/div[2]/div[2]/h3")
				if @browser.at_xpath("/html/body/div[1]/div/div[2]/div[4]/div[2]/div[1]/div[2]/div[2]/h3").text == "No exact matches"
					@finished = true
					break
				end
			end
			begin
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
		base = "https://www.domain.com.au/sale/#{suburb}/?ptype=duplex,free-standing,semi-detached&excludeunderoffer=1&ssubs=0&page=#{@counter}"
		# 'excludeunderoffer=1&ssubs=0&'
		return base
	end
	
	def process_request(domain_suburb, browser)
		@props = {}
		@browser = browser
		@counter = 1
		@finished = false
		until @finished do
			a = get_listing_links(build_url(domain_suburb))
			
			if a
				@props = @props.merge(a)
			end
			@counter += 1
		end
		return @props
	end

	def property_description(link, browser)
		retry_count = 0
		begin
			browser.go_to(link)
			if browser.at_css('div.css-14y7q63 > button')
				browser.at_css('div.css-14y7q63 > button').focus.click
			end 
			description = browser.at_css('#__next > div > div.css-1ktrj7 > div > div.css-4bd6g2 > div > div > div.css-bq4jj8').text
		rescue
			retry_count += 1
			puts "Unable to get description #{link}, retrying #{retry_count} time"
			retry if retry_count < 10
		end
		
		return description  
	end

	def get_browser
		browser = Ferrum::Browser.new(headless: false, 'no-sandbox' => false)
    browser.options.extensions.append('0.13.4_0.crx')
		return browser
	end

  def get_selenium
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_extension('0.13.4_0.crx')
    options.add_extension('1.58.0_0.crx')
    options.args << 'headless=new'
    a = Selenium::WebDriver.for :chrome, options: options
    return a
  end
  
  def pull_suburb(browser, suburb_tag)
    @counter = 1
    @property_list = {}
    @suburb_complete = false
    @browser = browser
    @browser.navigate.to(build_url(suburb_tag))
    until @suburb_complete do
      process_page
    end
    require 'pry'; binding.pry
  end

  def pull_suburb_history(browser, suburb_tag)
    target = "https://www.domain.com.au/sold-listings/#{suburb_tag}/house/?excludepricewithheld=1&ssubs=0"
    browser.navigate.to target
    @suburb_complete = false
    @browser = browser
    @sold_list = {}
    @counter = 1
    time = Time.now
    until @suburb_complete do
      process_sold_page
    end
    puts time - Time.now
    require 'pry'; binding.pry
  end

  def process_sold_page
    if @counter == 50
      @suburb_complete = true
      return
    end
    last = @browser.find_elements(css: '#skip-link-content > div.css-1ned5tb > div.css-1mf5g4s > ul > li').count < 23
    elements = @browser.find_elements(css: '#skip-link-content > div.css-1ned5tb > div.css-1mf5g4s > ul > li')
    elements.each do |i|
      begin
        @sold_list[i.find_element(css: 'a').attribute('href')] = {sold_price: get_sold_price(i), info: get_info(i), address: get_clean_address(i), specs: get_specs(i), sold_date: get_sold_date(i), listed_date: get_listed_date(i), link: get_href(i)} if is_listing?(i)
      rescue NoSuchElementError
        puts "Error Found"
        sleep 1
        retry
      end
    end
    puts "Page #{@counter} complete"
    @counter += 1
    next_page(last)
  end
  
  def process_page
    last = @browser.find_elements(css: '#skip-link-content > div.css-1ned5tb > div.css-1mf5g4s > ul > li').count < 23
    elements = @browser.find_elements(css: '#skip-link-content > div.css-1ned5tb > div.css-1mf5g4s > ul > li')
    elements.each_with_index do |i, idx|
      @property_list[i.find_element(css: 'a').attribute('href')] = {info: get_info(i), address: get_clean_address(i), specs: get_specs(i)} if is_listing?(i)
    end
    next_page(last)
  end

  def is_listing?(element)
    element.attribute('class').include?('css-1qp9106')
  end

  def get_href(element)
    element.find_element(css: 'a').attribute('href')
  end

  def get_listed_date(element)
    string = get_info(element).grep(/Listed/)
    a = extract_between(string[0], "(", ")")
    return a.to_date if a
    return a if !a
  end

  def get_info(element)
    valid_string = false
    until valid_string
      string = []
      element.find_elements(css: 'p').each { |i| string << i.text }
      if !string.join.include?('Loading')
        valid_string = true
      else
        sleep(1)
      end
    end
    return string
  end

  def get_sold_price(element)
    valid_string = false
    until valid_string
      string = []
      element.find_elements(css: 'p').each { |i| string << i.text }
      if !string.join.include?('Loading')
        valid_string = true
      else
        sleep(1)
      end
    end
    if string[0].length > 10
      return string[0].split('(').last.split(' ').first
    end
    return string[0]
  end

  def get_clean_address(element)
    element.find_element(css:'a > h2').text.gsub("\n", '')
  end

  def get_specs(element)
    valid = false
    count = 0
    until valid
      specs = element.find_elements(css: "div.css-k1qq7e > div > span").map(&:text)
      if specs.count > 1
        valid = true
      else
        puts "retrying #{count}"
        sleep(1)
      end
    end
    return specs.each {|i| i.gsub!("\n", " ")}
  end

  def get_sold_date(element)
    date = element.find_element(class: "css-1nj9ymt").text
    reg = Regexp.new('[0-9]{2}+ [A-Za-z]{3}+ [0-9]{4}')
    real_date = date.match(reg).to_s.to_date
  end

  def next_page(last)
    if !last
      @browser.navigate.to "#{@browser.find_elements(class: 'css-xixru3').last.attribute('href')}"
    else
      @suburb_complete = true
    end
  end

  def extract_between(string, start, ending)
    if string.is_a?(String)
      a = string.split(start).last.split(ending).first
      return a
    end
  end
end