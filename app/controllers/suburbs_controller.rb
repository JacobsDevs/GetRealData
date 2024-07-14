class SuburbsController < ApplicationController
	def index
		@suburbs = Suburb.all
	end

	def new
	end

	def create
		domain_tag = "#{params[:name]}-vic-#{params[:postcode]}"
		burb = Suburb.create!(suburb_params)
		burb.update!(domain_tag: domain_tag, processing: false)
		redirect_to suburbs_path
	end

	def setup
		GetSuburbJob.perform_async(params[:id])
	end

private
	def suburb_params
		params.permit(:name, :postcode)
	end
end