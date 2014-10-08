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

namespace :import do
  task :build_county_address_csv => :environment do
    StateImporter::CountyAddresses.generate_from_api!
  end
end
  