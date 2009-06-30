Factory.define :registrant do |f|
  f.name_title      "Mr."
  f.first_name      "John"
  f.last_name       "Public"
  f.email_address   { |reg| "#{reg.first_name}.#{reg.last_name}@example.com".downcase }
  f.date_of_birth   20.years.ago.to_date
  f.zip_code        "94113"
end
