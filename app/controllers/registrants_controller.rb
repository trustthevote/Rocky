class RegistrantsController < ApplicationController
  # GET /registrants/new
  def new
    @registrant = Registrant.new
  end

  # POST /registrants
  def create
    @registrant = Registrant.new(params[:registrant])
    if @registrant.advance_to_step_1!
      redirect_to registrant_step_2_path(@registrant)
    else
      render "new"
    end
  end
end
