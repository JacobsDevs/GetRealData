class Suburbs::PropertiesController < ApplicationController
	def index
		@suburb = Suburb.find(params[:suburb_id])
	end
end