require 'rails_helper'

RSpec.describe 'Suburb#new page' do
	it 'can create new suburbs' do
		visit '/suburbs'
		click_link 'New Suburb'
		fill_in 'Name', with: 'Sale'
		fill_in 'Postcode', with: '3850'
		click_button "Create Suburb"
		expect(current_path).to eq('/suburbs')
		save_and_open_page
		expect(page).to have_content('Name: Sale')
		expect(page).to have_content('Sale-vic-3850')
	end
end