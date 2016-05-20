class GoogleSyncService
  include Googleable

  def rake_sync
    users = User.all
    users.each do |user|
      @accounts = []
      @google_events_ids = []
      user.google_access_tokens.where('deleted IS NOT true').each do |google_access_token|
        authorize google_access_token
        @accounts << @service
      end
      @accounts.each do |service|
        account = account(service.authorization.access_token)
        parser = GoogleCalendars.new(user, service, account)
        parser.import_calendars
        # items << parser.items
        manage_deleted_events(parser.items, user)

      end
    end
  end

  private

  def manage_deleted_events(items, user)
    items.each { |item| @google_events_ids << item.id }
    local_events_ids = Event.where('google_event_id IS NOT NULL AND events.user_id = ?', user.id)
      .includes(:calendar)
      .where(calendars: {sync_with_google: true})
      .pluck(:google_event_id)
    compare_google_events_ids_with(local_events_ids)
  end

  def compare_google_events_ids_with(local_events_ids)
    result = local_events_ids - @google_events_ids
    Event.where('google_event_id in (?)', result).destroy_all
  end

  def account(access_token)
    uri = account_info_uri + access_token
    response = JSON.parse(open(uri).string)
    response['email']
  end
end
