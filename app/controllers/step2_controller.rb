class Step2Controller < ApplicationController

  # GET /registrants/:registrant_id/step_2
  def show
    @registrant = Registrant.find(params[:registrant_id])
  end

  # PUT /registrants/:registrant_id/step_2
  def update
    @registrant = Registrant.find(params[:registrant_id])
    @registrant.attributes = params[:registrant]
    if @registrant.advance_to_step_2!
      redirect_to registrant_step_3_path(@registrant)
    else
      render "show"
    end
  end
end
