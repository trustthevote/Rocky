namespace :utility do
  desc "Go through UI registrants and submit stale records to the core system and delete records for transfered data"
  task :process_ui_records => :environment do
    Registrant.process_ui_records
  end
  
  
  desc "Mark all stale registrations as abandoned and redact sensitive data"
  task :timeout_stale_registrations => :environment do
    Registrant.abandon_stale_records
  end
  
  desc "Mark all stale registrations as abandoned and redact sensitive data"
  task :remove_completed_registrants => :environment do
    Registrant.remove_completed_registrants
  end
  
  desc "Remove pdf directories that are past the expiration date"
  task :remove_buckets => :environment do
    BucketRemover.new.remove_buckets!
  end
  
  desc "Deliver reminder emails"
  task :deliver_reminders => :environment do
    ReminderMailer.new.deliver_reminders!
  end
  
end
