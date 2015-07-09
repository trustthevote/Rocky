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
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'rails_helper'))

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
      email.body.should include(RockyConf.pdf_host_name)
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
      email.from.should include(RockyConf.from_address)
      email.body.should include("http")
      email.body.should include(registrant.pdf_download_path)

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
      email.from.should include(RockyConf.from_address)
      
      email.body.should include("this-is-the-phone")
      email.body.should include("this-is-the-address")
      email.body.should include("this-is-the-url")
      
    end

    it "includes pixel tracking" do
      registrant = FactoryGirl.create(:maximal_registrant)
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.confirmation(registrant).deliver
      end
      email = ActionMailer::Base.deliveries.last
      email.body.should include("http://www.google-analytics.com/collect?v=1&tid=UA-1913089-11&cid=#{registrant.uid}&t=event&ec=email&ea=confirmation_open")
    end
    
    it "includes cancel reminders link" do
      registrant = FactoryGirl.create(:maximal_registrant)
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.confirmation(registrant).deliver
      end
      email = ActionMailer::Base.deliveries.last
      email.body.should match(%r{https://.*/registrants/#{registrant.to_param}/finish\?reminders=stop})
      email.from.should include(RockyConf.from_address)
      
    end
    
    it "includes state-specific note" do
      registrant = FactoryGirl.create(:maximal_registrant, :home_state=>GeoState['AZ'])
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.confirmation(registrant).deliver
      end
      email = ActionMailer::Base.deliveries.last
      email.body.should include("arizona-email-instructions")
    end

    it "uses partner template" do
      partner    = FactoryGirl.create(:partner, :whitelabeled => true)
      registrant = FactoryGirl.create(:maximal_registrant, :partner => partner, :locale => 'en', first_name: 'First')
      EmailTemplate.set(partner, 'confirmation.en', 'PDF: <%= @pdf_url %>')
      EmailTemplate.set_subject(partner, 'confirmation.en', '<%= @registrant_first_name %>, Here is your pdf')
      
      
      Notifier.confirmation(registrant).deliver
      email = ActionMailer::Base.deliveries.last
      email.body.should match(%r{PDF: http://.*source=email})
      email.subject.should == 'First, Here is your pdf'
      email.from.should include(RockyConf.from_address)
      
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
      email.from.should include(RockyConf.from_address)
      email.subject.should include("Thank you for using the online voter registration tool")
      assert_equal "UTF-8", email.charset
      assert_equal "quoted-printable", email.header['Content-Transfer-Encoding'].to_s
    end
    it "uses partner template" do
      partner    = FactoryGirl.create(:partner, :whitelabeled => true)
      registrant = FactoryGirl.create(:step_2_registrant, :partner => partner, :locale => 'en', :last_name=>"test the template")
      EmailTemplate.set(partner, 'thank_you_external.en', 'HI: <%= @registrant.last_name %>')
      EmailTemplate.set_subject(partner, 'thank_you_external.en', 'Thank you external')

      partner.chaser_pixel_tracking_code="<unused code for <%= @registrant.uid %> />"
      partner.thank_you_external_pixel_tracking_code="<some code for <%= @registrant.uid %> />"
      

      Notifier.thank_you_external(registrant).deliver
      email = ActionMailer::Base.deliveries.last
      email.body.should match(%r{HI: test the template})
      email.body.should include("<some code for #{registrant.uid} />")
      email.subject.should == 'Thank you external'
      email.from.should include(RockyConf.from_address)
    end
    it "sends from partner email when configured" do
      partner    = FactoryGirl.create(:partner, :whitelabeled => true, :from_email=>"custom@partner.org")
      registrant = FactoryGirl.create(:maximal_registrant, :partner => partner, :locale => 'en')
      Notifier.thank_you_external(registrant).deliver
      email = ActionMailer::Base.deliveries.last
      email.from.should include("custom@partner.org")      
    end
    it "includes pixel tracking" do
      registrant = FactoryGirl.create(:maximal_registrant)
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.thank_you_external(registrant).deliver
      end
      email = ActionMailer::Base.deliveries.last
      email.body.should include("http://www.google-analytics.com/collect?v=1&tid=UA-1913089-11&cid=#{registrant.uid}&t=event&ec=email&ea=state_integrated_open")
    end
    
  end

  describe "#reminder" do
    it "delivers the expected email" do
      registrant = FactoryGirl.create(:maximal_registrant, :reminders_left  => 1)
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.reminder(registrant).deliver
      end
      email = ActionMailer::Base.deliveries.last
      email.from.should include(RockyConf.from_address)
      
      email.body.should include("http")
      email.body.should include(registrant.pdf_download_path)
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
      email.from.should include(RockyConf.from_address)
      
      email.body.should include("this-is-the-phone")
      email.body.should include("this-is-the-address")
      email.body.should include("this-is-the-url")
    end

    it "includes pixel tracking" do
      registrant = FactoryGirl.create(:maximal_registrant)
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.reminder(registrant).deliver
      end
      email = ActionMailer::Base.deliveries.last
      email.body.should include("http://www.google-analytics.com/collect?v=1&tid=UA-1913089-11&cid=#{registrant.uid}&t=event&ec=email&ea=reminder_open")
    end
    
    it "delivers the expected email in a different locale" do
      registrant = FactoryGirl.create(:maximal_registrant, :locale => 'es')
      Notifier.reminder(registrant).deliver
      email = ActionMailer::Base.deliveries.last
      email.from.should include(RockyConf.from_address)
      
      email.subject.should include(I18n.t("email.reminder.subject", :locale => :es))
    end

    it "includes cancel reminders link" do
      registrant = FactoryGirl.create(:maximal_registrant)
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.reminder(registrant).deliver
      end
      email = ActionMailer::Base.deliveries.last
      email.from.should include(RockyConf.from_address)
      
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

  describe "#final_reminder" do
    it "delivers the expected email" do
      registrant = FactoryGirl.create(:maximal_registrant, :reminders_left  => 0)
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.final_reminder(registrant).deliver
      end
      email = ActionMailer::Base.deliveries.last
      email.from.should include(RockyConf.from_address)
      
      email.body.should include("http")
      email.body.should include(registrant.pdf_download_path)
      assert_equal "UTF-8", email.charset
      assert_equal "quoted-printable", email.header['Content-Transfer-Encoding'].to_s
    end

    it "includes state data" do
      registrant = FactoryGirl.create(:maximal_registrant, :reminders_left  => 0)
      registrant.home_state.registrar_phone = "this-is-the-phone"
      registrant.home_state.registrar_address = "this-is-the-address"
      registrant.home_state.registrar_url = "this-is-the-url"
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.final_reminder(registrant).deliver
      end
      email = ActionMailer::Base.deliveries.last
      email.from.should include(RockyConf.from_address)
      
      email.body.should include("this-is-the-phone")
      email.body.should include("this-is-the-address")
      email.body.should include("this-is-the-url")
    end

    it "includes pixel tracking" do
      registrant = FactoryGirl.create(:maximal_registrant)
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.final_reminder(registrant).deliver
      end
      email = ActionMailer::Base.deliveries.last
      email.body.should include("http://www.google-analytics.com/collect?v=1&tid=UA-1913089-11&cid=#{registrant.uid}&t=event&ec=email&ea=final_reminder_open")
    end
    
    it "delivers the expected email in a different locale" do
      registrant = FactoryGirl.create(:maximal_registrant, :locale => 'es')
      Notifier.final_reminder(registrant).deliver
      email = ActionMailer::Base.deliveries.last
      email.from.should include(RockyConf.from_address)
      
      email.subject.should include(I18n.t("email.final_reminder.subject", :locale => :es))
    end

    it "includes cancel reminders link" do
      registrant = FactoryGirl.create(:maximal_registrant)
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.final_reminder(registrant).deliver
      end
      email = ActionMailer::Base.deliveries.last
      email.from.should include(RockyConf.from_address)
      
      email.body.should match(%r{https://.*/registrants/#{registrant.to_param}/finish\?reminders=stop})
    end
    
    it "sends from partner email when configured" do
      partner    = FactoryGirl.create(:partner, :whitelabeled => true, :from_email=>"custom@partner.org")
      registrant = FactoryGirl.create(:maximal_registrant, :partner => partner, :locale => 'en')
      Notifier.final_reminder(registrant).deliver
      email = ActionMailer::Base.deliveries.last
      email.from.should include("custom@partner.org")      
    end
    
  end


  describe "#chaser" do
    it "delivers the expected email" do
      registrant = FactoryGirl.create(:maximal_registrant, :reminders_left  => 1)
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.chaser(registrant).deliver
      end
      email = ActionMailer::Base.deliveries.last
      email.from.should include(RockyConf.from_address)
      
      email.body.should include("http")
      assert_equal "UTF-8", email.charset
      assert_equal "quoted-printable", email.header['Content-Transfer-Encoding'].to_s
    end
    
    it "delivers the expected email in a different locale" do
      registrant = FactoryGirl.create(:maximal_registrant, :locale => 'es')
      Notifier.chaser(registrant).deliver
      email = ActionMailer::Base.deliveries.last
      email.from.should include(RockyConf.from_address)
      
      email.subject.should include(I18n.t("email.chaser.subject", :locale => :es))
    end
    
    it "includes pixel tracking" do
      registrant = FactoryGirl.create(:maximal_registrant)
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        Notifier.chaser(registrant).deliver
      end
      email = ActionMailer::Base.deliveries.last
      email.body.should include("http://www.google-analytics.com/collect?v=1&tid=UA-1913089-11&cid=#{registrant.uid}&t=event&ec=email&ea=chase_open")
    end
    
    it "uses partner template" do
      partner    = FactoryGirl.create(:partner, :whitelabeled => true)
      registrant = FactoryGirl.create(:maximal_registrant, :partner => partner, :locale => 'en', first_name: 'First')
      EmailTemplate.set(partner, 'chaser.en', "You didn't finish")
      EmailTemplate.set_subject(partner, 'chaser.en', '<%= @registrant_first_name %>, You can still register to vote')
      partner.chaser_pixel_tracking_code="<some code for <%= @registrant.uid %> />"
      
      Notifier.chaser(registrant).deliver
      email = ActionMailer::Base.deliveries.last
      email.body.should include("You didn't finish")
      email.body.should include("<some code for #{registrant.uid} />")
      email.subject.should == 'First, You can still register to vote'
      email.from.should include(RockyConf.from_address)

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
