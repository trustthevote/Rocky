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
require 'services/v2'
class Api::V2::RegistrationsController < Api::V2::BaseController

  # Lists registrations
  def index
    query = {
      :partner_id       => params[:partner_id],
      :partner_api_key  => params[:partner_API_key],
      :since            => params[:since],
      :email            => params[:email]
    }

    jsonp :registrations => V2::RegistrationService.find_records(query)
  rescue ArgumentError => e
    jsonp({ :message => e.message }, :status => 400)
  end

  # Creates the record and returns the URL to the PDF file or
  # the error message with optional invalid field name.
  def create
    pdf_path = V2::RegistrationService.create_record(params[:registration]).pdf_path
    jsonp :pdfurl => "https://#{PDF_HOST_NAME}#{pdf_path}"
  rescue V2::RegistrationService::ValidationError => e
    jsonp({ :field_name => e.field, :message => e.message }, :status => 400)
  rescue V2::RegistrationService::SurveyQuestionError => e
    jsonp({ :message => e.message }, :status=>400)
  rescue V2::UnsupportedLanguageError => e
    jsonp({ :message => e.message }, :status => 400)
  rescue ActiveRecord::UnknownAttributeError => e
    name = e.message.split(': ')[1]
    jsonp({ :field_name => name, :message => "Invalid parameter type" }, :status => 400)
  end

  # Creates the record
  def create_finish_with_state
    V2::RegistrationService.create_record(params[:registration], true)
    jsonp ''
  rescue V2::RegistrationService::ValidationError => e
    jsonp({ :field_name => e.field, :message => e.message }, :status => 400)
  rescue V2::UnsupportedLanguageError => e
    jsonp({ :message => e.message }, :status => 400)
  rescue ActiveRecord::UnknownAttributeError => e
    name = e.message.split(': ')[1]
    jsonp({ :field_name => name, :message => "Invalid parameter type" }, :status => 400)
  end

end
