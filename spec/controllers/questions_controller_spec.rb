require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe QuestionsController do

  describe "when logged in" do
    before(:each) do
      activate_authlogic
      @partner = Factory.create(:partner, :id => 5)
      PartnerSession.create(@partner)
    end

    describe "edit" do
      it "shows edit form" do
        get :edit
        assert_response :success
        assert_template "edit"
        assert_not_nil assigns[:partner]
      end
    end

    describe "update" do
      it "updates questions" do
        put :update, :partner => {
                        :survey_question_1_en => "What is your favorite color?",
                        :survey_question_1_es => "¿Cuál es tu color favorito?",
                        :survey_question_2_en => "What is the average airspeed velocity of an unladen swallow?",
                        :survey_question_2_es => ""
                      }
        assert_redirected_to partner_url
      end
    end
  end
end
