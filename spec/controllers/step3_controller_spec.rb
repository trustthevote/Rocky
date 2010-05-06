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
      assert_redirected_to registrant_step_4_url(assigns[:registrant])
    end

    it "should reject invalid input and show form again" do
      put :update, :registrant_id => @registrant.to_param, :registrant => Factory.attributes_for(:step_3_registrant, :state_id_number => nil)
      assert assigns[:registrant].step_3?
      assert assigns[:registrant].reload.step_2?
      assert_template "show"
    end

    it "should notice disabled javascript and override has_mailing_address" do
      put :update, :registrant_id => @registrant.to_param,
                   :registrant => Factory.attributes_for(:step_3_registrant, :prev_address => "submitted", :change_of_address => "0"),
                   :javascript_disabled => "1"
      assert assigns[:registrant].invalid?
      assert_template "show"
      put :update, :registrant_id => @registrant.to_param,
                   :registrant => Factory.attributes_for(:step_3_registrant, :prev_first_name => "submitted", :change_of_name => "0"),
                   :javascript_disabled => "1"
      assert assigns[:registrant].invalid?
      assert_template "show"
    end

    describe "when user is forwardable to external reg page" do
      it "should show user choice page" do
        stub(GeoState).online_registrars { [@registrant.home_state.abbreviation] }
        put :update, :registrant_id => @registrant.to_param, :registrant => Factory.attributes_for(:step_3_registrant,
                                                                                                    :change_of_name => "0")
        assert assigns[:registrant].step_3?
        assert_redirected_to registrant_external_url(assigns[:registrant])
      end
    end
  end
end