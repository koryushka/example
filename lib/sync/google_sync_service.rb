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

      user.google_access_tokens.where('synchronizable IS true AND revoked IS NOT true')
        .each do |google_access_token|
          authorize google_access_token
          accounts << [@service, google_access_token]
      end

      accounts.each do |service|
        access_token = service[0].authorization.access_token
        next unless access_token
        account = account(service[1])
        next unless account
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
      .where(calendars: {synchronizable: true, account: account})
      .pluck(:google_event_id)
  end

  def compare_ids(google_events_ids, local_events_ids)
    result =  local_events_ids - google_events_ids
    Event.where('google_event_id in (?)', result).destroy_all
  end

  def account(access_token)
    begin
      uri = ACCOUNT_INFO_URI + access_token.token
      response = JSON.parse(open(uri).string)
      response['email']
    rescue OpenURI::HTTPError => e
      access_token.revoke! if unauthorized?(e)
      false
    end
  end

  def unauthorized? e
    e.message == '401 Unauthorized'
  end
end
