namespace :google do
  desc 'Sync events with google calendar'
  task sync: :environment do
    google_parser = GoogleSyncService.new
    google_parser.rake_sync
    puts 'Success'
  end
end
