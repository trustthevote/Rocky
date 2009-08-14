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
      stub(@registrant).generate_pdf
      stub(Registrant).find_by_param.with(anything).returns(@registrant)
    end

    it "should update registrant and complete step 5" do
      put :update, :registrant_id => @registrant.to_param, :registrant => Factory.attributes_for(:step_5_registrant)
      assert_not_nil assigns[:registrant]
      assert assigns[:registrant].complete?
      assert_redirected_to download_registrant_url(assigns[:registrant])
    end

    it "should reject invalid input and show form again" do
      put :update, :registrant_id => @registrant.to_param, :registrant => Factory.attributes_for(:step_5_registrant, :attest_true => false)
      assert assigns[:registrant].step_5?
      assert assigns[:registrant].reload.step_4?
      assert_template "show"
    end

    describe "finalization" do
      it "invokes finalize on registrant" do
        mock(@registrant).finalize_registration
        put :update, :registrant_id => @registrant.to_param, :registrant => Factory.attributes_for(:step_5_registrant)
      end

      it "reload only sends one confirmation email" do
        assert_difference('ActionMailer::Base.deliveries.size', 1) do
          put :update, :registrant_id => @registrant.to_param, :registrant => Factory.attributes_for(:step_5_registrant)
          put :update, :registrant_id => @registrant.to_param, :registrant => Factory.attributes_for(:step_5_registrant)
        end
      end
    end
  end
end
