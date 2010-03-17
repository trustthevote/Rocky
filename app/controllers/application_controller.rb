class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  before_filter :ensure_https

  protected

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
