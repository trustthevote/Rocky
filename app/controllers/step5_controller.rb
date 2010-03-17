class Step5Controller < RegistrationStep
  CURRENT_STEP = 5

  protected

  def advance_to_next_step
    @registrant.advance_to_step_5
  end

  def next_url
    registrant_download_url(@registrant)
  end

  def redirect_when_eligible
    @registrant.wrap_up
    super
  end
end
