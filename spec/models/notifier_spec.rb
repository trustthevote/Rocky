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
      partner = Factory.create(:partner)
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.deliver_password_reset_instructions(partner)
      end
      email = ActionMailer::Base.deliveries.last
      email.body.should =~ /A request to reset your password has been made/i
      email.body.should include(partner.perishable_token)
    end
  end

  describe "#confirmation" do
    it "delivers the expected email" do
      registrant = Factory.create(:maximal_registrant)
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.deliver_confirmation(registrant)
      end
      email = ActionMailer::Base.deliveries.last
      email.body.should include("http")
      email.body.should include(registrant.pdf_path)
      assert_equal 1, email.parts.length
      assert_equal "utf-8", email.parts[0].charset
      assert_equal "quoted-printable", email.parts[0].encoding
    end

    it "includes state data" do
      registrant = Factory.create(:maximal_registrant)
      registrant.home_state.registrar_phone = "this-is-the-phone"
      registrant.home_state.registrar_address = "this-is-the-address"
      registrant.home_state.registrar_url = "this-is-the-url"
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.deliver_confirmation(registrant)
      end
      email = ActionMailer::Base.deliveries.last
      email.body.should include("this-is-the-phone")
      email.body.should include("this-is-the-address")
      email.body.should include("this-is-the-url")
    end

    it "includes cancel reminders link" do
      registrant = Factory.create(:maximal_registrant)
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.deliver_confirmation(registrant)
      end
      email = ActionMailer::Base.deliveries.last
      email.body.should match(%r{https://.*/registrants/#{registrant.to_param}/finish\?reminders=stop})
    end

    it "uses partner template" do
      partner    = Factory(:partner, :whitelabeled => true)
      registrant = Factory(:maximal_registrant, :partner => partner, :locale => 'en')
      EmailTemplate.set(partner, 'confirmation.en', 'PDF: <%= @pdf_url %>')

      Notifier.deliver_confirmation(registrant)
      email = ActionMailer::Base.deliveries.last
      email.body.should match(%r{PDF: http://.*source=email})
    end
  end

  describe "#reminder" do
    it "delivers the expected email" do
      registrant = Factory.create(:maximal_registrant, :reminders_left  => 1)
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.deliver_reminder(registrant)
      end
      email = ActionMailer::Base.deliveries.last
      email.body.should include("http")
      email.body.should include(registrant.pdf_path)
      assert_equal 1, email.parts.length
      assert_equal "utf-8", email.parts[0].charset
      assert_equal "quoted-printable", email.parts[0].encoding
    end

    it "includes state data" do
      registrant = Factory.create(:maximal_registrant, :reminders_left  => 1)
      registrant.home_state.registrar_phone = "this-is-the-phone"
      registrant.home_state.registrar_address = "this-is-the-address"
      registrant.home_state.registrar_url = "this-is-the-url"
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.deliver_reminder(registrant)
      end
      email = ActionMailer::Base.deliveries.last
      email.body.should include("this-is-the-phone")
      email.body.should include("this-is-the-address")
      email.body.should include("this-is-the-url")
    end

    it "delivers the expected email in a different locale" do
      registrant = Factory.create(:maximal_registrant, :locale => 'es')
      Notifier.deliver_reminder(registrant)
      email = ActionMailer::Base.deliveries.last
      email.subject.should include(I18n.t("email.reminder.subject", :locale => :es))
    end

    it "includes cancel reminders link" do
      registrant = Factory.create(:maximal_registrant)
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.deliver_reminder(registrant)
      end
      email = ActionMailer::Base.deliveries.last
      email.body.should match(%r{https://.*/registrants/#{registrant.to_param}/finish\?reminders=stop})
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
        Notifier.deliver_tell_friends(tell_params)
      end
      email = ActionMailer::Base.deliveries.last
      email.from.should include(tell_params[:tell_email])
      email.subject.should include(tell_params[:tell_subject])
      email.body.should include(tell_params[:tell_message])
    end
  end
end
