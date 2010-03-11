class Step3Controller < ApplicationController
  include RegistrationStep
  CURRENT_STEP = 3

  def update
    if params[:javascript_disabled] == "1" && params[:registrant]
      reg = params[:registrant]
      reg[:change_of_address] = !"#{reg[:prev_address]}#{reg[:prev_unit]}#{reg[:prev_city]}#{reg[:prev_zip_code]}".blank?
      reg[:change_of_name] = !"#{reg[:prev_first_name]}#{reg[:prev_middle_name]}#{reg[:prev_last_name]}".blank?
    end
    super
  end

  protected

  def advance_to_next_step
    @registrant.advance_to_step_3
  end

  def next_url
    registrant_step_4_url(@registrant)
  end

  def set_up_view_variables
    @registrant.prev_state ||= @registrant.home_state
    @state_id_tooltip = @registrant.state_id_tooltip
  end
end
