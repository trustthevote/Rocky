class Step2Controller < ApplicationController
  include RegistrationStep
  CURRENT_STEP = 2

  def update
    if params[:javascript_disabled] == "1" && params[:registrant]
      reg = params[:registrant]
      reg[:has_mailing_address] = !"#{reg[:mailing_address]}#{reg[:mailing_unit]}#{reg[:mailing_city]}#{reg[:mailing_zip_code]}".blank?
      # TODO: reg[:has_mailing_address] = reg.slice(:mailing_address, :mailing_unit, :mailing_city, :mailing_zip_code).any? {|p| !p.blank?}
    end
    super
  end

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
