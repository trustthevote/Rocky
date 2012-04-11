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
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Api::RegistrationsController do

  describe 'create' do
    specify { new_registration_response { mock(Registrant).pdf_path { '/123.pdf' } }.should \
      be_json_data({ :pdfurl => "https://example-util.com/123.pdf" }) }

    specify { new_registration_response { raise RegistrationService::ValidationError.new('invalid_field', 'Error message') }.should \
      be_json_validation_error('invalid_field', 'Error message') }

    specify { new_registration_response { raise UnsupportedLanguageError }.should \
      be_json_error 'Unsupported language' }

    specify { new_registration_response { raise(ActiveRecord::UnknownAttributeError, 'unknown attribute: attr') }.should \
      be_json_validation_error('attr', 'Invalid parameter type') }
  end

  describe 'index' do
    specify { registrations_response { raise ArgumentError.new('error') }.should be_json_error('error') }

    specify { registrations_response { [ :reg1, :reg2 ] }.should be_json_data({ :registrations => [ :reg1, :reg2 ] }) }
  end

  private

  def registrations_response(&block)
    query = { :partner_id => nil, :partner_password => nil, :since => nil }
    mock(RegistrationService).find_records(query, &block)
    get :index, :format => 'json'
    response
  end

  def new_registration_response(&block)
    data = {}
    mock(RegistrationService).create_record(data, &block)
    post :create, :format => 'json', :registration => data
    response
  end

end
