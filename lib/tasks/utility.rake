namespace :utility do
  desc "Mark all stale registrations as abandoned and redact sensitive data"
  task :timeout_stale_registrations => :environment do
    Registrant.abandon_stale_records
  end
end
