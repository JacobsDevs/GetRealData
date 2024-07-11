require 'rails_helper'

RSpec.describe Suburb, type: :model do
	before(:each) do
		@burb = Suburb.create!(name: 'Rosebud', domain_tag: 'rosebud-vic-3939')
	end
	xit 'exists' do
		expect(@burb.name).to eq('Rosebud')
	end
	xit 'can set itself up' do
		@burb.setup_search(@burb.domain_tag)
		expect(@burb.properties.count).to eq(20)
	end
	it 'does not create duplicates' do
		@burb.setup_search(@burb.domain_tag)
		@burb.setup_search(@burb.domain_tag)
		expect(@burb.properties.count).to eq(20)
	end
end