class GoogleSyncService
  include GoogleAuth

  def rake_sync
    users = User.all.pluck :id
    users.each do |id|
      # GoogleWorker.perform_async id #Add to sidekiq
      sync id #perform immediately
    end
  end

  def sync(user_id)
      user = User.find_by_id(user_id)
      puts "USER_ID #{user_id}"
      accounts = []

      user.google_access_tokens.where('deleted IS NOT true').each do |google_access_token|
        authorize google_access_token
        accounts << [@service, google_access_token]
      end if user

      accounts.each do |service|
        account = account(service[0].authorization.access_token)
        parser = GoogleCalendars.new(user, service, account)
        parser.import_calendars
        google_events_ids = get_google_events_ids(parser.items)
        local_events_ids = get_local_event_ids(user_id, account)
        compare_ids(google_events_ids, local_events_ids)
      end
  end

  private

  def get_google_events_ids(items)
    items.map { |item| item.id }
  end

  def get_local_event_ids(user_id, account)
    Event.where('google_event_id IS NOT NULL AND events.user_id = ?', user_id)
      .includes(:calendar)
      .where(calendars: {sync_with_google: true, account: account})
      .pluck(:google_event_id)
  end

  def compare_ids(google_events_ids, local_events_ids)
    result =  local_events_ids - google_events_ids
    Event.where('google_event_id in (?)', result).destroy_all
  end

  def account(access_token)
    uri = ACCOUNT_INFO_URI + access_token
    response = JSON.parse(open(uri).string)
    response['email']
  end
end
