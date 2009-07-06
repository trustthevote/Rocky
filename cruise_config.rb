# Project-specific configuration for CruiseControl.rb

Project.configure do |project|
  project.email_notifier.emails = ["rocky-dev+ci@googlegroups.com"]
end