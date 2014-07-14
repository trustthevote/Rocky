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
FactoryGirl.define do
  factory :step_1_registrant, :class => "registrant" do
    status          "step_1"
    partner_id      "1"
    locale          "en"
    sequence(:email_address) { |n| "registrant_#{n}@example.com" }
    date_of_birth   20.years.ago.to_date.strftime("%m/%d/%Y")
    home_zip_code   "15215"  # == Pennsylvania
    us_citizen      true
    has_state_license true
    will_be_18_by_election true
    #opt_in_email    true
    #opt_in_sms      true
  end

  factory :under_18_finished_registrant, :parent => :step_1_registrant do 
    date_of_birth   17.years.ago.to_date.strftime("%m/%d/%Y")
    status          "under_18"
  end

  factory :step_2_registrant, :parent => :step_1_registrant do 
    status          "step_2"
    name_title      "Mr."
    first_name      "John"
    last_name       "Public"
    home_address    "123 Market St."
    home_city       "San Francisco"
    # home_state      { GeoState['CA'] }
    has_state_license true
  end

  factory :step_3_registrant, :parent => :step_2_registrant do 
    status          "step_3"
    state_id_number "NONE"
    opt_in_sms      false
    race            "Hispanic"
    party           "Democratic"
  end

  factory :step_4_registrant, :parent => :step_3_registrant do 
    status          "step_4"
    opt_in_email    false
  end

  factory :step_5_registrant, :parent => :step_4_registrant do 
    status          "step_5"
  end

  factory :completed_registrant, :parent => :step_5_registrant do 
    status          "complete"
  end

  factory :maximal_registrant, :parent => :completed_registrant do 
    status              "complete"
    locale              "en"
    partner_id          "1"
    reminders_left      "3"
    date_of_birth       20.years.ago.to_date.strftime("%m/%d/%Y")
    email_address       "citizen@example.com"
    first_registration  false
    home_zip_code       "02134"
    us_citizen          true
    name_title          "Mrs."
    first_name          "Susan"
    middle_name         "Brownell"
    last_name           "Anthony"
    name_suffix         "III"
    home_address        "123 Civil Rights Way"
    home_unit           "Apt 2"
    home_city           "West Grove"
    # home_state          { GeoState['MA'] }
    has_mailing_address true
    mailing_address     "10 Main St"
    mailing_unit        "Box 5"
    mailing_city        "Adams"
    mailing_state_id    { GeoState['MA'].id }
    mailing_zip_code    "02135"
    party               "Decline to State"
    race                "White (not Hispanic)"
    state_id_number     "NONE"
    phone               "123-456-7890"
    phone_type          "Mobile"
    change_of_name      true
    prev_name_title     "Ms."
    prev_first_name     "Susana"
    prev_middle_name    "B."
    prev_last_name      "Antonia"
    prev_name_suffix    "Jr."
    change_of_address   true
    prev_address        "321 Civil Wrongs Way"
    prev_unit           "#9"
    prev_city           "Pittsburgh"
    prev_state_id          { GeoState["PA"].id }
    prev_zip_code       "15215"
    opt_in_email        true
    opt_in_sms          true
    partner_opt_in_email        true
    partner_opt_in_sms          true
    survey_answer_1     "blue"
    survey_answer_2     "fido"
    volunteer           true
    partner_volunteer   true
  end

  factory :api_v2_maximal_registrant, :parent => :maximal_registrant do 
    partner_opt_in_email        true
    partner_opt_in_sms          true
    volunteer           true
    partner_volunteer   true
    tracking_source       "tracking_source"
    tracking_id   "part_tracking_id"
    original_survey_question_1     "color?"
    original_survey_question_2     "dog name?"
    survey_answer_1     "blue"
    survey_answer_2     "fido"
    send_confirmation_reminder_emails false
    building_via_api_call true
  end

  factory :api_created_partner, :class=>'partner' do
    organization "Org Name"
    url "http://www.google.com"
    privacy_url "http://www.google.com/privacy"
    logo_url "http://www.rockthevote.com/assets/images/structure/home_rtv_logo.png"
    name "Contact Name"
    email "contact_email@rtv.org"
    phone "123 234 3456"
    address "123 Main St"
    city "Boston"
    state_id { GeoState["MA"].id }
    zip_code "02110"
    widget_image "rtv-234x60-v1.gif"
    survey_question_1_en  "One?"
    survey_question_2_en  "Two?"
    survey_question_1_es  "Uno?"
    survey_question_2_es  "Dos?"
    partner_ask_for_volunteers true
    external_tracking_snippet "<code>snippet</code>"
    registration_instructions_url "http://register.rockthevote.com/reg-instructions?l=<LOCALE>&s=<STATE>"
    survey_question_2_zh_tw "%E9%9B%BB%E5%AD%90%E9%83%B5%E4%BB%B6%E5%9C%B0%E5%9D%80"
    survey_question_1_ko "KO One"
    whitelabeled true
    from_email "custom-from@rtv.org"
    finish_iframe_url "http://example.com/iFrame-url"
    rtv_email_opt_in false
    rtv_sms_opt_in false
    ask_for_volunteers true
    partner_email_opt_in true
    partner_sms_opt_in true
    
    
  end

  factory :partner do
    sequence(:username)   { |n| "partner_#{n}" }
    email                 { |p| "#{p.username}@example.com" }
    password              "password"
    password_confirmation "password"
    name                  { |p| p.username && p.username.humanize }
    url                   { |p| "#{p.username}.example.com" }
    address               "123 Liberty Ave."
    city                  "Pittsburgh"
    state_id                 { GeoState['PA'].id }
    zip_code              "15215"
    phone                 "412-555-1234"
    organization          "Consolidated Amalgamated, Inc."
    survey_question_1_en  "Hello?"
    survey_question_2_en  "Outta here?"
  end

  factory :government_partner, :parent=>:partner do
    is_government_partner true
    government_partner_zip_codes ["90000"]
  end

  factory :whitelabel_partner, :parent=>:partner do
    api_key               "abc123"
    survey_question_1_en  "Q1 En"
    survey_question_1_es  "Q1 Es"
    survey_question_2_en  "Q2 En"
    survey_question_2_es  "Q2 Es"
    ask_for_volunteers          true
    partner_ask_for_volunteers  true
    whitelabeled                true
    rtv_email_opt_in            true
    partner_email_opt_in        true
    rtv_sms_opt_in              true
    partner_sms_opt_in          true
  end
end


