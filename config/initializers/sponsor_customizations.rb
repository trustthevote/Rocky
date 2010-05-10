BARCODE_PREFIX = "RTV"

SPONSOR_NAME = "Rock the Vote"
SPONSOR_NAME_CGI_ESCAPED = CGI.escape(SPONSOR_NAME)

FACEBOOK_CALLBACK_URL = CGI.escape("http://www.rockthevote.com/register/fb")

PARTNER_SIGNUP_URL = "http://www.rockthevote.com/partner"

FOOTER_LINK_BASE_URL = "http://www.rockthevote.com/voter-registration/online-application-system"

FOOTER_COPYRIGHT = "&copy; Copyright %d, Rock the Vote"

PARTNER_COMARKETING_TEXT = %Q(Numbers not as high as you'd like?\n<a href="http://www.rockthevote.com/partner/how-to-get-it-out-there.html" target="_blank">Here are some ways to help market your tool.</a>)

case RAILS_ENV
when "production"
  FROM_ADDRESS = "register@rockthevote.com"
  ActionMailer::Base.default_url_options = { :host => "register.rockthevote.com" }
when "staging"
  FROM_ADDRESS = "register@rockthevote.com"
  ActionMailer::Base.default_url_options = { :host => "rtvstaging.osuosl.org" }
when "development"
  FROM_ADDRESS = "rocky-dev@gmail.com"
  ActionMailer::Base.default_url_options = { :host => "register.example.com" }
else
  FROM_ADDRESS = "rocky@example.com"
  ActionMailer::Base.default_url_options = { :host => "register.example.com" }
end
