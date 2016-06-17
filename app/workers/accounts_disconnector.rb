class AccountsDisconnector
  include Sidekiq::Worker
  sidekiq_options queue: 'google_parser'


  def perform(account_id)
    account = GoogleAccessToken.find_by_id(account_id)
    account.calendars.includes(:events).destroy_all if account
  end

end
