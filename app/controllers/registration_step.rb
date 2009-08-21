module RegistrationStep
  def self.included(controller)
    controller.class_eval do
      layout "registration"
      before_filter :find_partner
    end
  end

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
        redirect_when_eligible
      else
        redirect_to ineligible_registrant_url(@registrant)
      end
    else
      render "show"
    end
  end

  def redirect_when_eligible
    redirect_to next_url
  end

  def find_registrant(special_case=nil)
    @registrant = Registrant.find_by_param!(params[:registrant_id] || params[:id])
    if @registrant.complete? && special_case.nil?
      raise ActiveRecord::RecordNotFound
    end
    I18n.locale = @registrant.locale
  end

  def find_partner
    session[:partner_id] = params[:partner] || session[:partner_id] || Partner.default_id
    @partner = Partner.find(session[:partner_id])
  end
end
