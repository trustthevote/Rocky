class Step3Controller < ApplicationController
  include RegistrationStep

  def current_step
    3
  end

  hide_action :current_step

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
