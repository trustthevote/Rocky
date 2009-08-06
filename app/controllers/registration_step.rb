module RegistrationStep
  def show
    find_registrant
    set_up_view_variables
  end

  def update
    find_registrant
    set_up_view_variables
    @registrant.attributes = params[:registrant]
    attempt_to_advance
  end

  protected

  def set_up_view_variables
  end

  def attempt_to_advance
    advance_to_next_step

    if @registrant.valid?
      @registrant.save_or_reject!
      if @registrant.eligible?
        redirect_to next_url
      else
        redirect_to ineligible_registrant_url(@registrant)
      end
    else
      render "show"
    end
  end

  def find_registrant
    @registrant = Registrant.find_by_param(params[:registrant_id] || params[:id])
    I18n.locale = @registrant.locale
  end
end

