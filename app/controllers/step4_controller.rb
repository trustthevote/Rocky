class Step4Controller < ApplicationController
  include RegistrationStep

  def show
    find_registrant
  end

  def update
    find_registrant
    @registrant.attributes = params[:registrant]
    if @registrant.advance_to_step_4!
      redirect_to registrant_step_5_path(@registrant)
    else
      render "show"
    end
  end

  protected

  def find_registrant
    super
    @question_1 = @registrant.partner.send("survey_question_1_#{@registrant.locale}")
    @question_2 = @registrant.partner.send("survey_question_2_#{@registrant.locale}")
  end
end
