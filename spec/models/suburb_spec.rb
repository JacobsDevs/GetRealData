require 'rails_helper'

RSpec.describe Suburb, type: :model do
	before(:each) do
		@burb = Suburb.create!(name: 'Rosebud', domain_tag: 'rosebud-vic-3939')
	end
	it 'exists' do
		expect(@burb.name).to eq('Rosebud')
	end
	it 'can set itself up' do
		@burb.setup_search(@burb.domain_tag)
		require 'pry'; binding.pry
	end
end