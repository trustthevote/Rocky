# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  helper_method :current_partner_session, :current_partner
  filter_parameter_logging :password, :password_confirmation
  
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
      flash[:notice] = "You must be logged in to access this page"
      redirect_to new_partner_session_url
      return false
    end
  end

  def require_no_partner
    if current_partner
      store_location
      flash[:notice] = "You must be logged out to access this page"
      redirect_to account_url
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

end
