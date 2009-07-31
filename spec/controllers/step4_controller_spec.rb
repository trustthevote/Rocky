require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Step4Controller do
  describe "#show" do
    it "should show the step 4 input form" do
      reg = Factory.create(:step_3_registrant)
      get :show, :registrant_id => reg.to_param
      assert assigns[:registrant].step_3?
      assert_not_nil assigns[:question_1]
      assert_not_nil assigns[:question_2]
      assert_template "show"
    end

    it "gets the questions for the current locale" do
      reg = Factory.create(:step_3_registrant)
      reg.partner.survey_question_1_en = "In English?"
      reg.partner.survey_question_1_es = "En Español?"
      reg.partner.save
      get :show, :registrant_id => reg.to_param
      assert_equal "In English?", assigns[:question_1]
      reg.locale = "es"
      reg.save(false)
      get :show, :registrant_id => reg.to_param
      assert_equal "En Español?", assigns[:question_1]
    end
  end

  describe "#update" do
    before(:each) do
      @registrant = Factory.create(:step_3_registrant)
    end

    it "should update registrant and complete step 4" do
      put :update, :registrant_id => @registrant.to_param, :registrant => Factory.attributes_for(:step_4_registrant)
      assert_not_nil assigns[:registrant]
      assert assigns[:registrant].step_4?
      assert_redirected_to registrant_step_5_url(assigns[:registrant])
    end

    it "should reject invalid input and show form again" do
      put :update, :registrant_id => @registrant.to_param, :registrant => Factory.attributes_for(:step_4_registrant, :state_id_number => nil)
      assert assigns[:registrant].step_3?
      assert_template "show"
    end
  end
end