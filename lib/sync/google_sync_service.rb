class GoogleSyncService
  include GoogleAuth

  def rake_sync
    users = User.all.pluck :id
    users.each do |id|
      # GoogleWorker.perform_async id #Add to sidekiq
      sync id #perform immediately
    end
  end

  def sync(user_id, google_access_token=nil, calendar_id=nil, after_notification=nil)

    user = User.find_by_id(user_id)
    accounts = []
    #move code to model
    if google_access_token
      authorize google_access_token
      accounts << [@service, google_access_token]
      if calendar_id
        calendar = Calendar.find_by(google_calendar_id: calendar_id,
          google_access_token_id: google_access_token.id)
        build_channel(google_access_token, calendar) if calendar
      end
    else
      puts "USER_ID #{user_id}"
      user.google_access_tokens.where('synchronizable IS true AND revoked IS NOT true')
        .each do |google_access_token|
          authorize google_access_token
          accounts << [@service, google_access_token]
      end
    end
    parse_google_events = parse_events(calendar_id, after_notification)

    accounts.each do |service|
      access_token = service[0].authorization.access_token
      next unless access_token
      account = account(service[1])
      next unless account
      parser = GoogleCalendars.new(user, service, account)
      parser.import_calendars(calendar_id, parse_google_events)
      if parse_google_events
        google_events_ids = get_google_events_ids(parser.items)
        local_events_ids = get_local_event_ids(user_id, account)
        compare_ids(google_events_ids, local_events_ids)
      end
    end

    if google_access_token
        build_channel(google_access_token)
        google_access_token.calendars.each do |calendar|
          build_channel(google_access_token, calendar)
      end
    end
  end

  private

  def parse_events(calendar_id, after_notification)
    if !calendar_id && after_notification
      false
    else
      true
    end
  end
  def build_channel(google_access_token, calendar = nil)
    object = calendar || google_access_token
    unless object.google_channel
      google_channel = object.build_google_channel
      notifier = GoogleNotifications.new(google_access_token)
      notifier.subscribe(calendar)
      resp_body = notifier.instance_eval {@body}
      resp_body = Rails.env.development? ? resp_body : JSON.parse(resp_body)
      Rails.logger.debug "RESPONSE FROM GOOGLE NOTIFY #{resp_body.inspect}"
      if channel_id = (resp_body['id'] || resp_body[:id])
        google_channel.update_attributes(uuid: channel_id, google_resource_id: resp_body['resourceId'])
      else
        Rails.logger.debug "GOOGLE NOTIFICATION ERROR: #{resp_body.inspect}"
      end
    end
  end

  def prepare_accounts(accounts, user)

  end

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
    Event.includes(:event_recurrences, :event_cancellations, :participations).where('google_event_id in (?)', result).destroy_all
  end

  def account(access_token)
    begin
      uri = ACCOUNT_INFO_URI + access_token.token
      response = JSON.parse(open(uri).string)
      response['email']
    rescue OpenURI::HTTPError => e
      access_token.revoke! if unauthorized?(e)
      p "An error occurred #{e.inspect}"
      false
    end
  end

  def unauthorized? e
    e.message == '401 Unauthorized'
  end
end
