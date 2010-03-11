class Step4Controller < ApplicationController
  include RegistrationStep
  CURRENT_STEP = 4

  protected

  def advance_to_next_step
    @registrant.advance_to_step_4
  end

  def next_url
    registrant_step_5_url(@registrant)
  end

  def set_up_view_variables
    @question_1 = @registrant.partner.send("survey_question_1_#{@registrant.locale}")
    @question_2 = @registrant.partner.send("survey_question_2_#{@registrant.locale}")
  end
end
