require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Step5Controller do
  describe "#show" do
    it "should show the step 5 input form" do
      reg = Factory.create(:step_4_registrant)
      get :show, :registrant_id => reg.to_param
      assert assigns[:registrant].step_4?
      assert_template "show"
    end
  end

  describe "#update" do
    before(:each) do
      @registrant = Factory.create(:step_4_registrant)
    end

    it "should update registrant and complete step 5" do
      put :update, :registrant_id => @registrant.to_param, :registrant => Factory.attributes_for(:step_5_registrant)
      assert_not_nil assigns[:registrant]
      assert assigns[:registrant].step_5?
      assert_redirected_to download_registrant_url(assigns[:registrant])
    end

    it "should reject invalid input and show form again" do
      put :update, :registrant_id => @registrant.to_param, :registrant => Factory.attributes_for(:step_5_registrant, :attest_true => false)
      assert assigns[:registrant].step_5?
      assert assigns[:registrant].reload.step_4?
      assert_template "show"
    end
  end
end
