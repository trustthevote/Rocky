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
require "#{Rails.root}/app/services/v3"
class Api::V3::RegistrationsController < Api::V3::BaseController

  skip_before_filter :authenticate_everything, :only=>[:pdf_ready, :stop_reminders]

  # Lists registrations
  def index
    query = {
      :partner_id       => params[:partner_id],
      :partner_api_key  => params[:partner_API_key],
      :since            => params[:since],
      :email            => params[:email]
    }

    jsonp :registrations => V3::RegistrationService.find_records(query)
  rescue ArgumentError => e
    jsonp({ :message => e.message }, :status => 400)
  end
  
  def index_gpartner
    query = {
      :gpartner_id       => params[:gpartner_id],
      :gpartner_api_key  => params[:gpartner_API_key],
      :since            => params[:since],
      :email            => params[:email]
    }

    jsonp :registrations => V3::RegistrationService.find_records(query)
  rescue ArgumentError => e
    jsonp({ :message => e.message }, :status => 400)
  end
  
  
  # Creates the record and returns the URL to the PDF file or
  # the error message with optional invalid field name.
  def create
    r = V3::RegistrationService.create_record(params[:registration])
    jsonp :pdfurl => "https://#{RockyConf.pdf_host_name}#{r.pdf_path}", :uid=>r.uid
  rescue V3::RegistrationService::ValidationError => e
    jsonp({ :field_name => e.field, :message => e.message }, :status => 400)
  rescue V3::RegistrationService::SurveyQuestionError => e
    jsonp({ :message => e.message }, :status=>400)
  rescue V3::UnsupportedLanguageError => e
    jsonp({ :message => e.message }, :status => 400)
  rescue ActiveRecord::UnknownAttributeError => e
    name = e.message.split(': ')[1]
    jsonp({ :field_name => name, :message => "Invalid parameter type" }, :status => 400)
  end

  # Creates the record
  def create_finish_with_state
    result = V3::RegistrationService.create_record(params[:registration], true)
    jsonp :registrations => result.to_finish_with_state_array
  rescue V3::RegistrationService::ValidationError => e
    jsonp({ :field_name => e.field, :message => e.message }, :status => 400)
  rescue V3::UnsupportedLanguageError => e
    jsonp({ :message => e.message }, :status => 400)
  rescue ActiveRecord::UnknownAttributeError => e
    name = e.message.split(': ')[1]
    jsonp({ :field_name => name, :message => "Invalid parameter type" }, :status => 400)
  end
  
  def pdf_ready
    query = {
      :UID              => params[:UID]
    }

    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Allow-Headers'] = '*'
    headers['Access-Control-Max-Age'] = "1728000"

    jsonp :pdf_ready => V3::RegistrationService.check_pdf_ready(query), :UID=>params[:UID]
  rescue Exception => e
    jsonp({ :message => e.message }, :status => 400)
  end
  
  def stop_reminders
    query = {
      :UID              => params[:UID]
    }

    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, OPTIONS'
    headers['Access-Control-Allow-Headers'] = '*'
    headers['Access-Control-Max-Age'] = "1728000"

    jsonp V3::RegistrationService.stop_reminders(query).merge(:UID=>params[:UID])
  rescue Exception => e
    jsonp({ :message => e.message }, :status => 400)
  end
  
  def bulk
    jsonp({
        :registrants_added=>V3::RegistrationService.bulk_create(params[:registrants], params[:partner_id], params[:partner_API_key])
    })
  rescue Exception => e
    jsonp({ :message => e.message }, :status => 400)
  end

end
