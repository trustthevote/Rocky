Given /^the following partner exists:$/ do |table|
  # table is a Cucumber::Ast::Table
  if (table.hashes.first["id"])
    @partner = Partner.find(table.hashes.first["id"])
  end
  @partner = Factory(:partner, table.hashes.first) unless @partner
end


Given /^that partner's css file exists$/ do
  stub(File).exists?.returns(true)
end

Given /^that partner's css file does not exist$/ do
  stub(File).exists?.returns(false)
end



Then /^I should see a link to the standard CSS$/ do
  response.body.should include("link href=\"/stylesheets/application.css")
  response.body.should include("link href=\"/stylesheets/registration.css")
end


Then /^I should see a link to that partner's CSS$/ do
  response.body.should include("link href=\"/partners/#{@partner.id}/application.css")
  response.body.should include("link href=\"/partners/#{@partner.id}/registration.css")
end
