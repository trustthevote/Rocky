require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/registrants/new.html.erb" do
  include RegistrantsHelper

  before(:each) do
    assigns[:registrant] = stub_model(Registrant,
      :new_record? => true
    )
  end

  it "renders new registrant form" do
    render

    response.should have_tag("form[action=?][method=post]", registrants_path) do
    end
  end
end
