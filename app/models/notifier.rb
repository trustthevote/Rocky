class Notifier < ActionMailer::Base
  def password_reset_instructions(partner)
    subject  "Password Reset Instructions"
    from FROM_ADDRESS
    recipients partner.email
    sent_on Time.now.to_s(:db)
    body :url => edit_password_reset_url(:id => partner.perishable_token)
  end
end
