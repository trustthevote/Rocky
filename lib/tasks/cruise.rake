desc "This task is run by CruiseControl Continuous Integration"

task :cruise do
  require 'geminstaller'
  GemInstaller.install(['--sudo'])
  Rake::Task["db:migrate"].invoke
  Rake::Task["default"].invoke            # rake db:test:prepare invokes db:bootstrap
  Rake::Task["features"].invoke
  # Rake::Task["features:selenium"].invoke    # TODO: get selenium running.  use sauce?
end
