class Step5Controller < ApplicationController

  def show
    @registrant = Registrant.find(params[:registrant_id])
  end

  def update
    @registrant = Registrant.find(params[:registrant_id])
    @registrant.attributes = params[:registrant]
    if @registrant.advance_to_step_5!
      redirect_to download_registrant_url(@registrant)
    else
      render "show"
    end
  end
end
