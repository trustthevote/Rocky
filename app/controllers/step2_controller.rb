class Step2Controller < ApplicationController
  include RegistrationStep

  def current_step
    2
  end

  hide_action :current_step

  protected
  
  def advance_to_next_step
    @registrant.advance_to_step_2
  end

  def next_url
    registrant_step_3_url(@registrant)
  end

  def set_up_view_variables
    @registrant.mailing_state ||= @registrant.home_state
    @state_parties = @registrant.state_parties
  end
end
