$LOAD_PATH.unshift(Rails.root + '/vendor/plugins/cucumber/lib') if File.directory?(Rails.root + '/vendor/plugins/cucumber/lib')

begin
  require 'cucumber/rake/task'

  Cucumber::Rake::Task.new(:features) do |t|
    t.fork = true
    t.cucumber_opts = ['--format', (ENV['CUCUMBER_FORMAT'] || 'pretty')]
  end
  task :features => 'db:test:prepare'

  namespace :features do
    Cucumber::Rake::Task.new(:selenium) do |t|
      t.fork = true
      t.cucumber_opts = ['--format', (ENV['CUCUMBER_FORMAT'] || 'pretty')]
      t.profile = 'selenium'
    end
    task :selenium => 'db:test:prepare'
  end

rescue LoadError
  desc 'Cucumber rake task not available'
  task :features do
    abort 'Cucumber rake task is not available. Be sure to install cucumber as a gem or plugin'
  end
end
