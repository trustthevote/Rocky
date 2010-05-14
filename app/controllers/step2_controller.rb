class Step2Controller < RegistrationStep
  CURRENT_STEP = 2

  def update
    if params[:javascript_disabled] == "1" && params[:registrant]
      reg = params[:registrant]
      if reg[:has_mailing_address] == "0"
        reg[:has_mailing_address] = !"#{reg[:mailing_address]}#{reg[:mailing_unit]}#{reg[:mailing_city]}#{reg[:mailing_zip_code]}".blank?
      end
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
