namespace :google do
  desc 'Sync events with google calendar'
  task sync: :environment do
    google_parser = Api::V1::GoogleCalendarsController.new
    #TODO parse all events for all users
  end
end
