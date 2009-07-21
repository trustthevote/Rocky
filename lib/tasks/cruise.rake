desc "This task is run by CruiseControl Continuous Integration"

task :cruise do
  require 'geminstaller'
  GemInstaller.install(['--sudo'])
  Rake::Task["db:migrate:reset"].invoke   # TODO: remove :reset when migrations stabilize
  Rake::Task["default"].invoke            # rake db:test:prepare invokes db:bootstrap
  Rake::Task["features"].invoke
  Rake::Task["features:selenium"].invoke
end
