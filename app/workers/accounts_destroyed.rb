class AccountsDestroyer
  include Sidekiq::Worker
  sidekiq_options queue: 'google_parser'

  def perform(account_id)
    account = GoogleAccessToken.find_by_id(account_id)
    if account && account.destroy
      account.unsubscribe! if account.google_channel
    end
  end

end
