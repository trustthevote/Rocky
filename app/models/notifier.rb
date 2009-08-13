class Notifier < ActionMailer::Base
  def password_reset_instructions(partner)
    subject "Password Reset Instructions"
    from FROM_ADDRESS
    recipients partner.email
    sent_on Time.now.to_s(:db)
    body :url => edit_password_reset_url(:id => partner.perishable_token)
  end

  def confirmation(registrant)
    subject I18n.t('email.confirmation.subject')
    from FROM_ADDRESS
    recipients registrant.email_address
    sent_on Time.now.to_s(:db)
    body :pdf_url => "http://#{default_url_options[:host]}#{registrant.pdf_path}",
         :locale => registrant.locale
  end
end
