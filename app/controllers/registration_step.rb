class RegistrationStep < ApplicationController
  CURRENT_STEP = -1
  include ApplicationHelper

  layout "registration"
  before_filter :find_partner

  rescue_from Registrant::AbandonedRecord do |exception|
    reg = exception.registrant
    redirect_to registrants_timeout_url(partner_locale_options(reg.partner.id, reg.locale, reg.tracking_source))
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

  def current_step
    self.class::CURRENT_STEP
  end
  hide_action :current_step

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
        redirect_to registrant_ineligible_url(@registrant)
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
    if (@registrant.complete? || @registrant.under_18?) && special_case.nil?
      raise ActiveRecord::RecordNotFound
    end
    I18n.locale = @registrant.locale
  end

  def find_partner
    if partner = Partner.find_by_id(params[:partner])
      @partner = partner
    else
      @partner = Partner.find(Partner.default_id)
    end
    @partner_id = @partner.id
    @source = params[:source]
  end
end
