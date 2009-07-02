Factory.define :step_1_registrant, :class => "registrant" do |f|
  f.status          "step_1"
  f.name_title      "Mr."
  f.first_name      "John"
  f.last_name       "Public"
  f.email_address   { |reg| "#{reg.first_name}.#{reg.last_name}@example.com".downcase }
  f.date_of_birth   20.years.ago.to_date
  f.home_zip_code   "94113"
end

Factory.define :step_2_registrant, :parent => :step_1_registrant do |f|
  f.status      "step_2"
  f.us_citizen  true
end