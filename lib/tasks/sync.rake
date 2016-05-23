namespace :google do
  desc 'Sync events with google calendar'
  task sync: :environment do
    google_parser = GoogleSyncService.new
    google_parser.rake_sync
    # GoogleWorker.perform_async()
    puts 'Success'
  end
end
