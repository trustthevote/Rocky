class IneligiblesController < RegistrationStep
  CURRENT_STEP = 1

  def show
    super
    if @registrant.ineligible_age? &&
        !(@registrant.ineligible_non_participating_state? || @registrant.ineligible_non_citizen?)
      @registrant.remind_when_18 = true
      render "under_18"
    end
  end

  def update
    find_registrant
    @registrant.update_attributes(params[:registrant])
    @registrant.request_reminder!
    redirect_to registrant_finish_url(@registrant)
  end
end
