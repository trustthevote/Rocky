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
class RegistrantsController < RegistrationStep
  CURRENT_STEP = 1

  # GET /widget_loader.js
  def widget_loader
    @host = host_url
  end

  # GET /registrants
  def landing
    find_partner
    options = {}
    options[:partner] = @partner.to_param if params[:partner]
    options[:locale] = params[:locale] if params[:locale]
    options[:source] = params[:source] if params[:source]
    options[:tracking] = params[:tracking] if params[:tracking]
    options[:short_form] = params[:short_form] if params[:short_form]
    options.merge!(:protocol => "https") unless Rails.env.development?
    redirect_to new_registrant_url(options)
  end

  # GET /registrants/new
  def new
    set_up_locale
    if MobileConfig.is_mobile_request?(request)
      redirect_to MobileConfig.redirect_url(:partner=>@partner_id, :locale=>@locale, :source=>@source, :tracking=>@tracking)
    else
      @registrant = Registrant.new(:partner_id => @partner_id, :locale => @locale, :tracking_source => @source, :tracking_id=>@tracking, :short_form=>@short_form)
      render "show"
    end
  end

  # POST /registrants
  def create
    set_up_locale
    @registrant = Registrant.new(params[:registrant].reverse_merge(
                                    :locale => @locale,
                                    :partner_id => @partner_id,
                                    :tracking_source => @source,
                                    :tracking_id => @tracking,
                                    :short_form => @short_form))
                                    
    if @registrant.partner.primary?
      @registrant.opt_in_email = true
      @registrant.opt_in_sms = true
    else
      if @registrant.partner.rtv_email_opt_in
        @registrant.opt_in_email = true
      end
      if @registrant.partner.rtv_sms_opt_in
        @registrant.opt_in_sms = true
      end 
      if @registrant.partner.partner_email_opt_in
        @registrant.partner_opt_in_email = true
      end
      if @registrant.partner.partner_sms_opt_in
        @registrant.partner_opt_in_sms = true
      end
    end
    attempt_to_advance
  end

  protected

  def set_up_locale
    @locale = params[:locale] || 'en'
    I18n.locale = @locale.to_sym
  end

  def advance_to_next_step
    @registrant.advance_to_step_1
  end

  def next_url
    registrant_step_2_url(@registrant)
  end

  def host_url
    "#{request.protocol}#{request.host_with_port}"
  end

end
