class Step5Controller < ApplicationController
  include RegistrationStep

  def current_step
    5
  end

  hide_action :current_step


  private

  def advance_to_next_step
    @registrant.advance_to_step_5
  end

  def next_url
    download_registrant_url(@registrant)
  end
end
