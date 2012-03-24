# file: import.rake
# task: rake import:states

namespace :import do
  desc "Import state and state localization data from CSV_FILE"
  task :states => :environment do
    path = ENV["CSV_FILE"] || "states.csv"
    puts path
    File.open(path) do |file|
      StateImporter.import(file)
    end
  end
end
