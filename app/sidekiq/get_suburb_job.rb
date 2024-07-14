class GetSuburbJob
  include Sidekiq::Job

  def perform(*args)
		id = args[0].to_i
		burb = Suburb.find(id)
		burb.update!(processing: true)
		burb.setup_search(burb.domain_tag)
		burb.update!(processing: false)
  end
end
