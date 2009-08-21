class RegistrantsController < ApplicationController
  include RegistrationStep

  # GET /registrants/new
  def new
    locale = params[:locale] || 'en'
    I18n.locale = locale.to_sym
    @alt_locale_options = {}
    @alt_locale_options[:locale] = 'es' if locale == 'en'
    @registrant = Registrant.new(:partner_id => session[:partner_id], :locale => locale)
    render "show"
  end

  # POST /registrants
  def create
    @registrant = Registrant.new(params[:registrant].reverse_merge(
                                    :partner_id => session[:partner_id],
                                    :opt_in_sms => true, :opt_in_email => true))
    I18n.locale = @registrant.locale
    attempt_to_advance
  end

  def ineligible
    find_registrant
  end

  def timeout
    @current_step = 0
  end

  def download
    @current_step = 6
    find_registrant(:download)
  end

  def current_step
    @current_step ||= 1
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
