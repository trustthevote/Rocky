class Step3Controller < ApplicationController
  include RegistrationStep

  protected

  def advance_to_next_step
    @registrant.advance_to_step_3
  end

  def next_url
    registrant_step_4_url(@registrant)
  end

  def set_up_view_variables
    @registrant.prev_state ||= @registrant.home_state
  end
end
