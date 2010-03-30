class PartnerBase < ApplicationController
  layout "partners"
  helper_method :current_partner_session, :current_partner
  filter_parameter_logging :password, :password_confirmation
  before_filter :init_nav_class


  protected

  def current_partner_session
    return @current_partner_session if defined?(@current_partner_session)
    @current_partner_session = PartnerSession.find
  end

  def current_partner
    return @current_partner if defined?(@current_partner)
    @current_partner = current_partner_session && current_partner_session.record
  end

  def require_partner
    unless current_partner
      store_location
      flash[:warning] = "You must be logged in to access this page"
      redirect_to login_url
      return false
    end
  end

  def force_logout
    current_partner_session.destroy if current_partner
    remove_instance_variable :@current_partner_session if defined?(@current_partner_session)
    remove_instance_variable :@current_partner if defined?(@current_partner)
    reset_session
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def init_nav_class
    @nav_class = Hash.new
  end
end
