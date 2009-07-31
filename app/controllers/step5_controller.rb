class Step5Controller < ApplicationController
  include RegistrationStep

  def show
    find_registrant
  end

  def update
    find_registrant
    @registrant.attributes = params[:registrant]
    if @registrant.advance_to_step_5!
      redirect_to download_registrant_url(@registrant)
    else
      render "show"
    end
  end
end
