class Step3Controller < ApplicationController
  include RegistrationStep

  def show
    find_registrant
  end

  def update
    find_registrant
    @registrant.attributes = params[:registrant]
    if @registrant.advance_to_step_3!
      redirect_to registrant_step_4_url(@registrant)
    else
      render "show"
    end
  end
end
