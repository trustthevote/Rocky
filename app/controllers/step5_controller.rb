class Step5Controller < ApplicationController
  include RegistrationStep

  def show
    find_registrant
  end

  def update
    find_registrant
    @registrant.attributes = params[:registrant]
    @registrant.advance_to_step_5

    if @registrant.valid?
      @registrant.save_or_reject!
      if @registrant.eligible?
        redirect_to download_registrant_url(@registrant)
      else
        redirect_to ineligible_registrant_url(@registrant)
      end
    else
      render "show"
    end

  end
end
