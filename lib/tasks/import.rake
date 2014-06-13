# file: import.rake
# task: rake import:states

namespace :import do
  desc "Import state and state localization data from the standard file"
  task :states => :environment do
    si = StateImporter.new
    si.import
    puts "All imports valid, comitting to DB..."
    si.commit!
    puts "Import Done!"
  end
end
