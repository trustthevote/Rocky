class StateOnlineRegistrationsController < RegistrationStep
  

  protected
  
  def set_up_view_variables
    @online_registration_iframe_url = case @registrant.home_state_name
    when "Washington"
      fn = CGI.escape @registrant.first_name.to_s
      ln = CGI.escape @registrant.last_name.to_s
      dob= CGI.escape @registrant.form_date_of_birth.to_s.gsub('-','/')
      "http://198.238.204.92/myvote?Org=RocktheVote&firstname=#{fn}&lastName=#{ln}&DOB=#{dob}"
    when "Arizona"
      "https://servicearizona.com/webapp/evoter/selectLanguage"
    when "California"
      "https://www.sos.ca.gov/elections/register-to-vote/"
    else
      ""
    end    
  end
  
  
end
