class Step2Controller < ApplicationController
  include RegistrationStep

  def update
    if params[:javascript_disabled] == "1" && params[:registrant]
      reg = params[:registrant]
      reg[:has_mailing_address] = !"#{reg[:mailing_address]}#{reg[:mailing_unit]}#{reg[:mailing_city]}#{reg[:mailing_zip_code]}".blank?
    end
    super
  end

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
    @race_tooltip = @registrant.race_tooltip
    @party_tooltip = @registrant.party_tooltip
  end
end
