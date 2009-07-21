# file: bootstrap.rake
# task: rake db:bootstrap
#
# Load initial database state from fixtures in db/bootstrap directory.
# Add subdirectories named for environments to load specific fixtures
# for that environment.

require 'active_record'
require 'active_record/fixtures'

def load_fixtures_in_dir(dir)
  Dir.glob(File.join(RAILS_ROOT, dir, '*.{yml,csv}')).each do |fixture_file|
    Fixtures.create_fixtures(dir, File.basename(fixture_file, '.*'))
  end
  Dir.glob(File.join(RAILS_ROOT, dir, '*.{rb}')).each do |ruby_file|
    load ruby_file
  end
end

namespace :db do
  desc "Seed db with initial data."
  task :bootstrap => :environment do

    env = ENV["RAILS_ENV"] || "development"

    env_dir = File.join('db', 'bootstrap', env)

    load_fixtures_in_dir(File.join('db', 'bootstrap'))
    load_fixtures_in_dir(env_dir) # override common fixtures for this environment
  end
  namespace :bootstrap do
    task :update => :environment do
      Fixtures.create_fixtures(File.join('db', 'bootstrap'), "enumerations")
    end
  end
  
  desc "migrate:reset and then bootstrap"
  task :reboot => %w[db:migrate:reset db:bootstrap]

  namespace :test do
    task :prepare do
      Rake::Task["db:bootstrap"].invoke
    end
  end
end
