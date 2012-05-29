When /^I upload the "([^\"]*)" zip file$/ do |file_name|
  attach_file(:partner_zip_zip_file, File.join(RAILS_ROOT, 'spec', 'fixtures', 'files', file_name))
end