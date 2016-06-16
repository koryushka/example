class GoogleWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'google_parser'

  # def initialize()
  #   @syncronizer = GoogleSyncService.new
  # end

  def perform(id, account=nil)
    # ids.each do |id|
      GoogleSyncService.new.sync(id, account)
    # end
  end

end
