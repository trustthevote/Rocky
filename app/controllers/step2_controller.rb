class Step2Controller < ApplicationController
  include RegistrationStep

  # GET /registrants/:registrant_id/step_2
  def show
    find_registrant
  end

  # PUT /registrants/:registrant_id/step_2
  def update
    find_registrant
    @registrant.attributes = params[:registrant]
    if @registrant.advance_to_step_2!
      redirect_to registrant_step_3_url(@registrant)
    else
      render "show"
    end
  end

  protected

  def find_registrant
    super
    @state_parties = @registrant.state_parties
  end
end
