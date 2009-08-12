# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  helper_method :current_partner_session, :current_partner
  filter_parameter_logging :password, :password_confirmation

  before_filter :ensure_https

  def current_step
    -1
  end

  hide_action :current_step

  private

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

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  # override in subclass controller if plain HTTP is allowed
  def require_https?
    true
  end

  def ensure_https
    if USE_HTTPS && require_https? && !request.ssl?
      flash.keep
      url = URI.parse(request.url)
      url.scheme = "https"
      redirect_to(url.to_s)
      false
    end
  end
end
