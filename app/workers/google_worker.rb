class GoogleWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'google_parser'

  # def initialize()
  #   @syncronizer = GoogleSyncService.new
  # end

  def perform(id, account=nil, calendar_id=nil, after_notification=nil, account_id=nil)
    # ids.each do |id|
      GoogleSyncService.new.sync(id, account_id)
    # end
  end

end
