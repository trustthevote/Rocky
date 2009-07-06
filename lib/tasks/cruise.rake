desc "This task is run by CruiseControl Continuous Integration"

task :cruise do
  require 'geminstaller'
  GemInstaller.install(['--sudo'])
  Rake::Task['db:migrate'].invoke
  Rake::Task[:default].invoke
end
