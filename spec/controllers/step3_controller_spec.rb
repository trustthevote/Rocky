require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Step3Controller do
  describe "#show" do
    it "should show the step 3 input form" do
      reg = Factory.create(:step_2_registrant)
      get :show, :registrant_id => reg.to_param
      assert assigns[:registrant].step_2?
      assert_template "show"
    end
  end

  describe "#update" do
    before(:each) do
      @registrant = Factory.create(:step_2_registrant)
    end

    it "should update registrant and complete step 3" do
      put :update, :registrant_id => @registrant.to_param, :registrant => Factory.attributes_for(:step_3_registrant)
      assert_not_nil assigns[:registrant]
      assert assigns[:registrant].step_3?
      assert_redirected_to registrant_step_4_path(assigns[:registrant])
    end

    it "should reject invalid input and show form again" do
      put :update, :registrant_id => @registrant.to_param, :registrant => Factory.attributes_for(:step_3_registrant, :state_id_number => nil)
      assert assigns[:registrant].step_2?
      assert_template "show"
    end
  end
end