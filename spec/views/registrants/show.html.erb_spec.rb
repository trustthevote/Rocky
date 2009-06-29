require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/registrants/show.html.erb" do
  include RegistrantsHelper
  before(:each) do
    assigns[:registrant] = @registrant = stub_model(Registrant)
  end

  it "renders attributes in <p>" do
    render
  end
end
