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
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe Notifier do
  attr_reader :email

  describe "#password_reset_instruction" do
    it "delivers the expected email" do
      partner = FactoryGirl.create(:partner)
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.password_reset_instructions(partner).deliver
      end
      email = ActionMailer::Base.deliveries.last
      email.body.should =~ /A request to reset your password has been made/i
      email.body.should include(partner.perishable_token)
    end
  end

  describe "#confirmation" do
    it "delivers the expected email" do
      registrant = FactoryGirl.create(:maximal_registrant)
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.confirmation(registrant).deliver
      end
      email = ActionMailer::Base.deliveries.last
      email.from.should include(Settings.from_address)
      email.body.should include("http")
      email.body.should include(registrant.pdf_path)

      assert_equal "UTF-8", email.charset
      assert_equal "quoted-printable", email.header['Content-Transfer-Encoding'].to_s
    end

    it "includes state data" do
      registrant = FactoryGirl.create(:maximal_registrant)
      registrant.home_state.registrar_phone = "this-is-the-phone"
      registrant.home_state.registrar_address = "this-is-the-address"
      registrant.home_state.registrar_url = "this-is-the-url"
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.confirmation(registrant).deliver
      end
      email = ActionMailer::Base.deliveries.last
      email.from.should include(Settings.from_address)
      
      email.body.should include("this-is-the-phone")
      email.body.should include("this-is-the-address")
      email.body.should include("this-is-the-url")
    end

    it "includes cancel reminders link" do
      registrant = FactoryGirl.create(:maximal_registrant)
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.confirmation(registrant).deliver
      end
      email = ActionMailer::Base.deliveries.last
      email.body.should match(%r{https://.*/registrants/#{registrant.to_param}/finish\?reminders=stop})
      email.from.should include(Settings.from_address)
      
    end

    it "uses partner template" do
      partner    = FactoryGirl.create(:partner, :whitelabeled => true)
      registrant = FactoryGirl.create(:maximal_registrant, :partner => partner, :locale => 'en')
      EmailTemplate.set(partner, 'confirmation.en', 'PDF: <%= @pdf_url %>')

      Notifier.confirmation(registrant).deliver
      email = ActionMailer::Base.deliveries.last
      email.body.should match(%r{PDF: http://.*source=email})
      email.from.should include(Settings.from_address)
      
    end
    
    it "sends from partner email when configured" do
      partner    = FactoryGirl.create(:partner, :whitelabeled => true, :from_email=>"custom@partner.org")
      registrant = FactoryGirl.create(:maximal_registrant, :partner => partner, :locale => 'en')
      Notifier.confirmation(registrant).deliver
      email = ActionMailer::Base.deliveries.last
      email.from.should include("custom@partner.org")      
    end
  end


  describe "#thank_you_external" do
    it "delivers the expected email" do
      registrant = FactoryGirl.create(:maximal_registrant)
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.thank_you_external(registrant).deliver
      end
      email = ActionMailer::Base.deliveries.last
      email.to.should include(registrant.email_address)
      email.from.should include(Settings.from_address)
      email.subject.should include("Thank you for using the online voter registration tool")
      assert_equal "UTF-8", email.charset
      assert_equal "quoted-printable", email.header['Content-Transfer-Encoding'].to_s
    end
    it "uses partner template" do
      partner    = FactoryGirl.create(:partner, :whitelabeled => true)
      registrant = FactoryGirl.create(:step_2_registrant, :partner => partner, :locale => 'en', :last_name=>"test the template")
      EmailTemplate.set(partner, 'thank_you_external.en', 'HI: <%= @registrant.last_name %>')

      Notifier.thank_you_external(registrant).deliver
      email = ActionMailer::Base.deliveries.last
      email.body.should match(%r{HI: test the template})
      email.from.should include(Settings.from_address)
    end
    it "sends from partner email when configured" do
      partner    = FactoryGirl.create(:partner, :whitelabeled => true, :from_email=>"custom@partner.org")
      registrant = FactoryGirl.create(:maximal_registrant, :partner => partner, :locale => 'en')
      Notifier.thank_you_external(registrant).deliver
      email = ActionMailer::Base.deliveries.last
      email.from.should include("custom@partner.org")      
    end
    
  end

  describe "#reminder" do
    it "delivers the expected email" do
      registrant = FactoryGirl.create(:maximal_registrant, :reminders_left  => 1)
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.reminder(registrant).deliver
      end
      email = ActionMailer::Base.deliveries.last
      email.from.should include(Settings.from_address)
      
      email.body.should include("http")
      email.body.should include(registrant.pdf_path)
      assert_equal "UTF-8", email.charset
      assert_equal "quoted-printable", email.header['Content-Transfer-Encoding'].to_s
    end

    it "includes state data" do
      registrant = FactoryGirl.create(:maximal_registrant, :reminders_left  => 1)
      registrant.home_state.registrar_phone = "this-is-the-phone"
      registrant.home_state.registrar_address = "this-is-the-address"
      registrant.home_state.registrar_url = "this-is-the-url"
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.reminder(registrant).deliver
      end
      email = ActionMailer::Base.deliveries.last
      email.from.should include(Settings.from_address)
      
      email.body.should include("this-is-the-phone")
      email.body.should include("this-is-the-address")
      email.body.should include("this-is-the-url")
    end

    it "delivers the expected email in a different locale" do
      registrant = FactoryGirl.create(:maximal_registrant, :locale => 'es')
      Notifier.reminder(registrant).deliver
      email = ActionMailer::Base.deliveries.last
      email.from.should include(Settings.from_address)
      
      email.subject.should include(I18n.t("email.reminder.subject", :locale => :es))
    end

    it "includes cancel reminders link" do
      registrant = FactoryGirl.create(:maximal_registrant)
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.reminder(registrant).deliver
      end
      email = ActionMailer::Base.deliveries.last
      email.from.should include(Settings.from_address)
      
      email.body.should match(%r{https://.*/registrants/#{registrant.to_param}/finish\?reminders=stop})
    end
    it "sends from partner email when configured" do
      partner    = FactoryGirl.create(:partner, :whitelabeled => true, :from_email=>"custom@partner.org")
      registrant = FactoryGirl.create(:maximal_registrant, :partner => partner, :locale => 'en')
      Notifier.reminder(registrant).deliver
      email = ActionMailer::Base.deliveries.last
      email.from.should include("custom@partner.org")      
    end
    
  end

  describe "#tell_friends" do
    it "delivers the expected emails" do
      tell_params = {
        :tell_from => "Bob Dobbs",
        :tell_email => "bob@example.com",
        :tell_recipients => "obo@example.com",
        :tell_subject => "Register to vote the easy way",
        :tell_message => "I registered to vote and you can too."
      }
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.tell_friends(tell_params).deliver
      end
      email = ActionMailer::Base.deliveries.last
      email.from.should include(tell_params[:tell_email])
      email.subject.should include(tell_params[:tell_subject])
      email.body.should include(tell_params[:tell_message])
    end
  end
end
