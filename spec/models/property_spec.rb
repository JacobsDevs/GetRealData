require 'rails_helper'

RSpec.describe Property, type: :model do
	before(:each) do
		@burb = Suburb.create!(name: 'Rosebud', domain_tag: 'rosebud-vic-3939')
		@prop = @burb.properties.create!(address: '1 Test st, Test')
		@data = {"https://www.domain.com.au/19-mccombe-street-rosebud-vic-3939-2019334737"=>{"address"=>"19 McCombe Street, ROSEBUD VIC 3939", "price"=>"$1,300,000 - $1,400,000 ", "beds"=>"3 Beds", "baths"=>"1 Bath", "cars"=>"1 Parking", "land"=>"836m² "}, "https://www.domain.com.au/150-jones-road-rosebud-vic-3939-2019089632"=>{"address"=>"150 Jones Road, ROSEBUD VIC 3939", "price"=>"Private Sale | $6,800,000 - $7,400,000 ", "beds"=>"5.65ha ", "baths"=>nil, "cars"=>nil, "land"=>nil}, "https://www.domain.com.au/101-866-point-nepean-road-rosebud-vic-3939-2019304728"=>{"address"=>"101/866 Point Nepean Road, ROSEBUD VIC 3939", "price"=>"$ 1,025,000 ", "beds"=>"2 Beds", "baths"=>"2 Baths", "cars"=>"1 Parking", "land"=>nil}}
	end
	it 'exists' do
		expect(@prop.address).to eq('1 Test st, Test')
	end
	it 'can build from page data' do
		@burb.properties.build_from_page_data(@data)

		expect(@burb.properties.count).to eq(4)
	end
	it 'can get description from link' do
		@burb.properties.build_from_page_data(@data)

		property = @burb.properties.last
		property.get_description_from_link
		
		expect(@burb.properties.last.description).to include("Banksia")
	end
end