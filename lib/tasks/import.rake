# file: import.rake
# task: rake import:states

namespace :import do
  desc "Import state and state localization data from the standard file"
  task :states => :environment do
    path = Rails.root.join('db/bootstrap/import/states.yml')
    puts path
    File.open(path) do |file|
      StateImporter.import(file)
    end
  end
end
