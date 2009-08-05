class Step5Controller < ApplicationController
  include RegistrationStep

  private

  def advance_to_next_step
    @registrant.advance_to_step_5
  end

  def next_url
    download_registrant_url(@registrant)
  end
end
