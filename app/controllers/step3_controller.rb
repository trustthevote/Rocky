class Step3Controller < ApplicationController

  def show
    @registrant = Registrant.find(params[:registrant_id])
  end

  def update
    @registrant = Registrant.find(params[:registrant_id])
    @registrant.attributes = params[:registrant]
    if @registrant.advance_to_step_3!
      flash[:success] = "Gotcha"
      redirect_to registrant_step_4_path(@registrant)
    else
      render "show"
    end
  end
end
