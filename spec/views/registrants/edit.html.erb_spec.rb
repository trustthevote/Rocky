require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "/registrants/edit.html.erb" do
  include RegistrantsHelper

  before(:each) do
    assigns[:registrant] = @registrant = stub_model(Registrant,
      :new_record? => false
    )
  end

  it "renders the edit registrant form" do
    render

    response.should have_tag("form[action=#{registrant_path(@registrant)}][method=post]") do
    end
  end
end
