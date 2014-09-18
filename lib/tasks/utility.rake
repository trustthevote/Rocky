namespace :utility do
  desc "Mark all stale registrations as abandoned and redact sensitive data"
  task :timeout_stale_registrations => :environment do
    Registrant.abandon_stale_records
  end
  
  desc "Remove pdf directories that are past the expiration date"
  task :remove_buckets => :environment do
    BucketRemover.new.remove_buckets!
  end
  
  desc "Deliver reminder emails"
  task :remove_buckets => :environment do
    ReminderMailer.new.deliver_reminders!
  end
  
end
