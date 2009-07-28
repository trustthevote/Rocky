class Step4Controller < ApplicationController

  def show
    @registrant = Registrant.find(params[:registrant_id])
    @question_1 = @registrant.partner.send("survey_question_1_#{@registrant.locale}")
    @question_2 = @registrant.partner.send("survey_question_2_#{@registrant.locale}")
  end

  def update
    @registrant = Registrant.find(params[:registrant_id])
    @registrant.attributes = params[:registrant]
    if @registrant.advance_to_step_4!
      redirect_to registrant_step_5_path(@registrant)
    else
      render "show"
    end
  end
end
