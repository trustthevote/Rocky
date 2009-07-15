Factory.define :step_1_registrant, :class => "registrant" do |f|
  f.status          "step_1"
  f.locale          "en"
  f.sequence(:email_address) { |n| "registrant_#{n}@example.com" }
  f.date_of_birth   20.years.ago.to_date
  f.home_zip_code   "00001"  # == Pennsylvania
  f.us_citizen      true
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
end

Factory.define :step_3_registrant, :parent => :step_2_registrant do |f|
  f.status          "step_3"
  f.state_id_number "2345"
end