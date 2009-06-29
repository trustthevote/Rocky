require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/registrants/index.html.erb" do
  include RegistrantsHelper

  before(:each) do
    assigns[:registrants] = [
      stub_model(Registrant),
      stub_model(Registrant)
    ]
  end

  it "renders a list of registrants" do
    render
  end
end
