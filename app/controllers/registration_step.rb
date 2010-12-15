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
class RegistrationStep < ApplicationController
  CURRENT_STEP = -1
  include ApplicationHelper

  layout "registration"
  before_filter :find_partner
  filter_parameter_logging :state_id_number

  rescue_from Registrant::AbandonedRecord do |exception|
    reg = exception.registrant
    redirect_to registrants_timeout_url(partner_locale_options(reg.partner.id, reg.locale, reg.tracking_source))
  end

  def show
    find_registrant
    set_up_view_variables
  end

  def update
    find_registrant
    set_up_view_variables
    @registrant.attributes = params[:registrant]
    attempt_to_advance
  end

  def current_step
    self.class::CURRENT_STEP
  end
  hide_action :current_step

  protected

  def set_up_view_variables
  end

  def attempt_to_advance
    advance_to_next_step

    if @registrant.valid?
      @registrant.save_or_reject!
      if @registrant.eligible?
        redirect_when_eligible
      else
        redirect_to registrant_ineligible_url(@registrant)
      end
    else
      render "show"
    end
  end

  def redirect_when_eligible
    redirect_to next_url
  end

  def find_registrant(special_case=nil)
    @registrant = Registrant.find_by_param!(params[:registrant_id] || params[:id])
    if (@registrant.complete? || @registrant.under_18?) && special_case.nil?
      raise ActiveRecord::RecordNotFound
    end
    I18n.locale = @registrant.locale
  end

  def find_partner
    @partner = Partner.find_by_id(params[:partner]) || Partner.find(Partner.default_id)
    @partner_id = @partner.id
    @source = params[:source]
  end
end
