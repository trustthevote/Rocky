Factory.define :step_1_registrant, :class => "registrant" do |f|
  f.status          "step_1"
  f.association     :partner, :factory => :partner
  f.locale          "en"
  f.sequence(:email_address) { |n| "registrant_#{n}@example.com" }
  f.date_of_birth   20.years.ago.to_date.strftime("%m/%d/%Y")
  f.home_zip_code   "15215"  # == Pennsylvania
  f.us_citizen      true
  f.opt_in_email    true
  f.opt_in_sms      true
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
  f.survey_answer_1     "blue"
  f.survey_answer_2     "fido"
  f.volunteer           true
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
  partner.logo_image_url        "https://example.com/logo.jpg"
  partner.survey_question_1_en  "Hello?"
  partner.survey_question_2_en  "Outta here?"
end
