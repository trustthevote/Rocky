class RegistrantsController < ApplicationController
  include RegistrationStep

  # GET /registrants/new
  def new
    partner_id = params[:partner] || Partner.default_id
    locale = params[:locale] || 'en'
    I18n.locale = locale.to_sym
    @alt_locale_options = {}
    @alt_locale_options[:locale] = 'es' if locale == 'en'
    @alt_locale_options[:partner] = partner_id if partner_id.to_i != Partner.default_id
    @registrant = Registrant.new(:partner_id => partner_id, :locale => locale)
    render "show"
  end

  # POST /registrants
  def create
    @registrant = Registrant.new(params[:registrant])
    I18n.locale = @registrant.locale
    attempt_to_advance
  end

  def ineligible
    find_registrant
  end

  def download
    find_registrant(:download)
  end

  def current_step
    action_name == "download" ? 6 : 1
  end

  hide_action :current_step

  protected
  
  def advance_to_next_step
    @registrant.advance_to_step_1
  end

  def next_url
    registrant_step_2_url(@registrant)
  end
end
