namespace :admin do

  # Resets the password
  desc "Resets the admin password"
  task :reset_password => :environment do
    new_pass = SecureRandom.hex(4)
    Settings.admin_password = new_pass
    puts "New admin password: #{new_pass}"
  end

end
