require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Step2Controller do
  describe "#show" do
    it "should show the step 2 input form" do
      reg = Factory.create(:step_1_registrant)
      get :show, :registrant_id => reg.id
      assert assigns[:registrant].step_1?
      assert_template "show"
    end
  end

  describe "#update" do
    before(:each) do
      @registrant = Factory.create(:step_1_registrant)
    end

    it "should update registrant and complete step 2" do
      put :update, :registrant_id => @registrant.id, :registrant => Factory.attributes_for(:step_2_registrant)
      assert_not_nil assigns[:registrant]
      assert assigns[:registrant].step_2?
      assert_redirected_to new_registrant_step_3_path(assigns[:registrant])
    end

    it "should reject invalid input and show form again" do
      put :update, :registrant_id => @registrant.id, :registrant => Factory.attributes_for(:step_2_registrant, :first_name => nil)
      assert assigns[:registrant].step_1?
      assert_template "show"
    end
  end
end