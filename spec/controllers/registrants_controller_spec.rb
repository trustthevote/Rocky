require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe RegistrantsController do
  describe "#create" do
    it "should create a new registrant and complete step 1" do
      post :create, :registrant => Factory.attributes_for(:step_1_registrant)
      assert_not_nil assigns[:registrant]
      assert_redirected_to new_registrant_step_2_path(assigns[:registrant])
    end
  end
end
