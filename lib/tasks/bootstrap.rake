# file: bootstrap.rake
# task: rake db:bootstrap
#
# Load initial database state from fixtures in db/bootstrap directory.
# Add subdirectories named for environments to load specific fixtures
# for that environment.

require 'active_record'
require 'active_record/fixtures'

def load_fixtures_in_dir(dir)
  Dir.glob(File.join(Rails.root, dir, '*.{yml}')).each do |fixture_file|
    ActiveRecord::Fixtures.create_fixtures(dir, File.basename(fixture_file, '.*'))
  end
  Dir.glob(File.join(Rails.root, dir, '*.{rb}')).each do |ruby_file|
    load ruby_file
  end
end

namespace :db do
  desc "Seed db with initial data."
  task :bootstrap => :environment do

    env = Rails.env || "development"

    env_dir = File.join('db', 'bootstrap', env)

    load_fixtures_in_dir(File.join('db', 'bootstrap'))
    load_fixtures_in_dir(env_dir) # override common fixtures for this environment

    GeoState.reset_all_states
    Rake::Task["import:states"].execute
  end
  
  desc "migrate:reset and then bootstrap"
  task :reboot => %w[db:migrate:reset db:bootstrap]

  desc "backfill registrant data (age, official_party_name)"
  task :backfill_data => :environment do
    Registrant.backfill_data
  end
end
