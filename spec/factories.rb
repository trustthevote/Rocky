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
Factory.define :step_1_registrant, :class => "registrant" do |f|
  f.status          "step_1"
  #f.association     :partner, :factory => :primary_partner
  f.partner_id      "1"
  f.locale          "en"
  f.sequence(:email_address) { |n| "registrant_#{n}@example.com" }
  f.date_of_birth   20.years.ago.to_date.strftime("%m/%d/%Y")
  f.home_zip_code   "15215"  # == Pennsylvania
  f.us_citizen      true
  #f.opt_in_email    true
  #f.opt_in_sms      true
end

Factory.define :under_18_finished_registrant, :parent => :step_1_registrant do |f|
  f.date_of_birth   17.years.ago.to_date.strftime("%m/%d/%Y")
  f.status          "under_18"
end

Factory.define :step_2_registrant, :parent => :step_1_registrant do |f|
  f.status          "step_2"
  f.name_title      "Mr."
  f.first_name      "John"
  f.last_name       "Public"
  f.home_address    "123 Market St."
  f.home_city       "San Francisco"
  # f.home_state      { GeoState['CA'] }
  f.has_state_license false
  f.race            "Hispanic"
  f.party           "None"
end

Factory.define :step_3_registrant, :parent => :step_2_registrant do |f|
  f.status          "step_3"
  f.state_id_number "2345"
  f.opt_in_sms      false
end

Factory.define :step_4_registrant, :parent => :step_3_registrant do |f|
  f.status          "step_4"
  f.opt_in_email    false
end

Factory.define :step_5_registrant, :parent => :step_4_registrant do |f|
  f.status          "step_5"
end

Factory.define :completed_registrant, :parent => :step_5_registrant do |f|
  f.status          "complete"
end

Factory.define :maximal_registrant, :parent => :completed_registrant do |f|
  f.status              "complete"
  f.locale              "en"
  f.partner_id          "1"
  f.reminders_left      "3"
  f.date_of_birth       20.years.ago.to_date.strftime("%m/%d/%Y")
  f.email_address       "citizen@example.com"
  f.first_registration  false
  f.home_zip_code       "02134"
  f.us_citizen          true
  f.name_title          "Mrs."
  f.first_name          "Susan"
  f.middle_name         "Brownell"
  f.last_name           "Anthony"
  f.name_suffix         "III"
  f.home_address        "123 Civil Rights Way"
  f.home_unit           "Apt 2"
  f.home_city           "West Grove"
  # f.home_state          { GeoState['MA'] }
  f.has_mailing_address true
  f.mailing_address     "10 Main St"
  f.mailing_unit        "Box 5"
  f.mailing_city        "Adams"
  f.mailing_state_id    { GeoState['MA'] }
  f.mailing_zip_code    "02135"
  f.party               "Decline to State"
  f.race                "White (not Hispanic)"
  f.state_id_number     "5678"
  f.phone               "123-456-7890"
  f.phone_type          "Mobile"
  f.change_of_name      true
  f.prev_name_title     "Ms."
  f.prev_first_name     "Susana"
  f.prev_middle_name    "B."
  f.prev_last_name      "Antonia"
  f.prev_name_suffix    "Jr."
  f.change_of_address   true
  f.prev_address        "321 Civil Wrongs Way"
  f.prev_unit           "#9"
  f.prev_city           "Pittsburgh"
  f.prev_state          { GeoState["PA"] }
  f.prev_zip_code       "15215"
  f.opt_in_email        true
  f.opt_in_sms          true
  f.partner_opt_in_email        true
  f.partner_opt_in_sms          true
  f.survey_answer_1     "blue"
  f.survey_answer_2     "fido"
  f.volunteer           true
  f.partner_volunteer   true
end

Factory.define :api_v2_maximal_registrant, :parent => :maximal_registrant do |f|
  f.partner_opt_in_email        true
  f.partner_opt_in_sms          true
  f.volunteer           true
  f.partner_volunteer   true
  f.tracking_source       "tracking_source"
  f.tracking_id   "part_tracking_id"
  f.original_survey_question_1     "color?"
  f.original_survey_question_2     "dog name?"
  f.survey_answer_1     "blue"
  f.survey_answer_2     "fido"
  
end

Factory.define :api_created_partner, :class=>'partner' do |p|
  p.organization "Org Name"
  p.url "http://www.google.com"
  p.privacy_url "http://www.google.com/privacy"
  p.logo_url "http://www.rockthevote.com/assets/images/structure/home_rtv_logo.png"
  p.name "Contact Name"
  p.email "contact_email@rtv.org"
  p.phone "123 234 3456"
  p.address "123 Main St"
  p.city "Boston"
  p.state_id {GeoState["MA"]}
  p.zip_code "02110"
  p.widget_image "rtv-234x60-v1.gif"
  p.survey_question_1_en  "One?"
  p.survey_question_2_en  "Two?"
  p.survey_question_1_es  "Uno?"
  p.survey_question_2_es  "Dos?"
  p.partner_ask_for_volunteers true
end

Factory.define :partner do |partner|
  partner.sequence(:username)   { |n| "partner_#{n}" }
  partner.email                 { |p| "#{p.username}@example.com" }
  partner.password              "password"
  partner.password_confirmation "password"
  partner.name                  { |p| p.username && p.username.humanize }
  partner.url                   { |p| "#{p.username}.example.com" }
  partner.address               "123 Liberty Ave."
  partner.city                  "Pittsburgh"
  partner.state                 { GeoState['PA'] }
  partner.zip_code              "15215"
  partner.phone                 "412-555-1234"
  partner.organization          "Consolidated Amalgamated, Inc."
  partner.survey_question_1_en  "Hello?"
  partner.survey_question_2_en  "Outta here?"
end

Factory.define :whitelabel_partner, :parent=>:partner do |partner|
  partner.api_key               "abc123"
  partner.survey_question_1_en  "Q1 En"
  partner.survey_question_1_es  "Q1 Es"
  partner.survey_question_2_en  "Q2 En"
  partner.survey_question_2_es  "Q2 Es"
  partner.ask_for_volunteers          true
  partner.partner_ask_for_volunteers  true
  partner.whitelabeled                true
  partner.rtv_email_opt_in            true
  partner.partner_email_opt_in        true
  partner.rtv_sms_opt_in              true
  partner.partner_sms_opt_in          true
end



