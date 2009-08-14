class Step5Controller < ApplicationController
  include RegistrationStep

  def current_step
    5
  end

  hide_action :current_step

  def update
    find_registrant
    @registrant.attributes = params[:registrant]

    @registrant.advance_to_step_5 unless @registrant.complete? # already been here

    if @registrant.valid?
      @registrant.save_or_reject!
      if @registrant.eligible?
        @registrant.finalize_registration
        redirect_to next_url
      else
        redirect_to ineligible_registrant_url(@registrant)
      end
    else
      render "show"
    end
  end
  

  private

  def advance_to_next_step
    @registrant.advance_to_step_5
  end

  def next_url
    download_registrant_url(@registrant)
  end
end
