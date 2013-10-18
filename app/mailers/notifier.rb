#***** BEGIN LICENSE BLOCK *****
#
#Version: RTV Public License 1.0
#
#The contents of this file are subject to the RTV Public License Version 1.0 (the
#"License"); you may not use this file except in compliance with the License. You
#may obtain a copy of the License at: http://www.osdv.org/license12b/
#
#Software distributed under the License is distributed on an "AS IS" basis,
#WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for the
#specific language governing rights and limitations under the License.
#
#The Original Code is the Online Voter Registration Assistant and Partner Portal.
#
#The Initial Developer of the Original Code is Rock The Vote. Portions created by
#RockTheVote are Copyright (C) RockTheVote. All Rights Reserved. The Original
#Code contains portions Copyright [2008] Open Source Digital Voting Foundation,
#and such portions are licensed to you under this license by Rock the Vote under
#permission of Open Source Digital Voting Foundation.  All Rights Reserved.
#
#Contributor(s): Open Source Digital Voting Foundation, RockTheVote,
#                Pivotal Labs, Oregon State University Open Source Lab.
#
#***** END LICENSE BLOCK *****
class Notifier < ActionMailer::Base
  def password_reset_instructions(partner)
    @url = edit_password_reset_url(:id => partner.perishable_token)
    
    mail(:subject=> "Password Reset Instructions",
         :from => RockyConf.from_address,
         :to => partner.email,
         :date => Time.now.to_s(:db))
  end

  def confirmation(registrant)
    setup_registrant_email(registrant, 'confirmation')
  end

  def thank_you_external(registrant)
    setup_registrant_email(registrant, 'thank_you_external')
  end

  def reminder(registrant)
    setup_registrant_email(registrant, 'reminder')
  end

  def tell_friends(tell_params)
    @message = tell_params[:tell_message]
    mail(:subject => tell_params[:tell_subject],
      :from => "#{tell_params[:tell_from]} <#{tell_params[:tell_email]}>",
      :to => tell_params[:tell_recipients],
      :date => Time.now.to_s(:db))
    
  end

  protected

  def setup_registrant_email(registrant, kind)
    
    m = mail(:subject=> I18n.t("email.#{kind}.subject", :locale => registrant.locale.to_sym),
      :from=>registrant.email_address_to_send_from,
      :to=>registrant.email_address,
      :date=> Time.now.to_s(:db)) do |format|
        format.html { message_body(registrant, kind) }
    end

    m.transport_encoding = "quoted-printable"
    
    m

  end

  def message_body(registrant, kind)
    @pdf_url = "http://#{default_url_options[:host]}#{registrant.pdf_path}?source=email"
    @cancel_reminders_url = registrant_finish_url(registrant, :protocol => "https", :reminders => "stop")
    @locale               = registrant.locale.to_sym
    @registrar_phone      = registrant.home_state.registrar_phone
    @registrar_address    = registrant.home_state.registrar_address.to_s.html_safe
    @registrar_url        = registrant.home_state.registrar_url
    @registrant           = registrant

    partner = registrant.partner
    custom_template = partner && partner.whitelabeled? && EmailTemplate.get(partner, "#{kind}.#{registrant.locale}")

    if custom_template
      render :inline => custom_template
    else
      render "notifier/#{kind}"
    end
  end

  # Wrapper for the custom template
  class Template
    def initialize(body)
      @body = body
    end

    # Need to keep this method to satisfy internal checks of ActionMailer
    def render(*args)
    end

    def render_template(view, *args)
      view.render :inline => @body
    end
  end

end
