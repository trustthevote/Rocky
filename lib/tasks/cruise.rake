desc "This task is run by CruiseControl Continuous Integration"

task :cruise do
  require 'geminstaller'
  GemInstaller.install(['--sudo'])
  Rake::Task['db:migrate:reset'].invoke   # TODO: remove :reset when migrations stabilize
  Rake::Task[:default].invoke
  Rake::Task[:features].invoke
end
