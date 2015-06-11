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
require File.dirname(__FILE__) + '/../rails_helper'

describe EmailTemplate do

  describe "TEMPLATE_NAMES" do
    it "includes confirmation and reminders for all locales" do
      I18n.available_locales.each do |locale|
        EmailTemplate::TEMPLATE_NAMES.should include(
          ["confirmation.#{locale}", "Confirmation #{locale.to_s.upcase}"]
        )
        EmailTemplate::TEMPLATE_NAMES.should include(
          ["reminder.#{locale}", "Reminder #{locale.to_s.upcase}"]
        )
      end      
    end
  end

  before { @p = FactoryGirl.create(:partner) }
  before { EmailTemplate.set(@p, 'confirmation.en', 'body') }

  describe 'set_subject' do
    it 'should set an email subject fo the partner' do
      EmailTemplate.set_subject(@p, 'confirmation.en', 'email subject')
      EmailTemplate.order("updated_at DESC").last.subject.should == 'email subject'
    end    
  end
  describe 'get_subject' do
    it 'should get an email subject fo the partner' do
      EmailTemplate.set_subject(@p, 'confirmation.en', 'retrieve subject')
      EmailTemplate.get_subject(@p, 'confirmation.en').should == 'retrieve subject'
    end    
  end

  it 'should set a template for the partner' do
    EmailTemplate.get(@p, 'confirmation.en').should == 'body'
  end

  it 'should update a template for the partner' do
    EmailTemplate.set(@p, 'confirmation.en', 'new body')
    EmailTemplate.get(@p, 'confirmation.en').should == 'new body'
  end

  it 'should not return a missing template for the partner' do
    EmailTemplate.get(@p, 'missing').should be_nil
  end

  it 'should check if template is present' do
    EmailTemplate.present?(@p, 'confirmation.en').should be_truthy
    EmailTemplate.present?(@p, 'missing').should be_falsey
  end

end
