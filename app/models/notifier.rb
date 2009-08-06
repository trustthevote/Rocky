class Notifier < ActionMailer::Base
  default_url_options[:host] = "rocky"

  def password_reset_instructions(partner)
    subject  "Password Reset Instructions"
    from "rtv@example.com" # FIXME: use real email address
    recipients partner.email
    sent_on Time.now.to_s(:db)
    body :url => edit_password_reset_url(:id => partner.perishable_token)
  end
end
