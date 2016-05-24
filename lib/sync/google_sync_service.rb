class GoogleSyncService
  include Googleable

  def rake_sync
    users = User.all.pluck :id
    # users.each_slice(5) do |ids|
    #   GoogleWorker.perform_async ids
    # end
    users.each do |id|
      GoogleWorker.perform_async id
      # sync id
    end

  end

  def sync(user_id)
      user = User.find_by_id(user_id)
      puts "USER_ID #{user_id}"
      accounts = []
      user.google_access_tokens.where('deleted IS NOT true').each do |google_access_token|
        authorize google_access_token
        accounts << @service
      end
      accounts.each do |service|
        account = account(service.authorization.access_token)
        parser = GoogleCalendars.new(user, service, account)
        parser.import_calendars
        # manage_deleted_events(parser.items, user_id, account)
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
    uri = account_info_uri + access_token
    response = JSON.parse(open(uri).string)
    response['email']
  end
end
