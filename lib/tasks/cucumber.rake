$LOAD_PATH.unshift(RAILS_ROOT + '/vendor/plugins/cucumber/lib') if File.directory?(RAILS_ROOT + '/vendor/plugins/cucumber/lib')

begin
  require 'cucumber/rake/task'

  namespace :features do
    Cucumber::Rake::Task.new(:webrat) do |t|
      t.fork = true
      t.cucumber_opts = ['--format', (ENV['CUCUMBER_FORMAT'] || 'pretty')]
      t.profile = 'default'
    end
    task :webrat => 'db:test:prepare'

    Cucumber::Rake::Task.new(:selenium) do |t|
      t.fork = true
      t.cucumber_opts = ['--format', (ENV['CUCUMBER_FORMAT'] || 'pretty')]
      t.profile = 'selenium'
    end
    task :selenium => 'db:test:prepare'
  end

  task :features => ["features:webrat", "features:selenium"]

rescue LoadError
  desc 'Cucumber rake task not available'
  task :features do
    abort 'Cucumber rake task is not available. Be sure to install cucumber as a gem or plugin'
  end
end
