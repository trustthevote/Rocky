class StateOnlineRegistrationsController < RegistrationStep

protected
  
  def set_up_view_variables
    set_up_share_variables
    
    
    @online_registration_iframe_url = case @registrant.home_state_name
    when "Arizona"
      "https://servicearizona.com/webapp/evoter/selectLanguage"
    when "California"
      "https://www.sos.ca.gov/elections/register-to-vote/"
    when "Colorado"
      "https://www.sos.state.co.us/Voter/secuVerifyExist.do"
    when "Washington"
      fn = CGI.escape @registrant.first_name.to_s
      ln = CGI.escape @registrant.last_name.to_s
      dob= CGI.escape @registrant.form_date_of_birth.to_s.gsub('-','/')
      lang= @registrant.locale
      "https://weiapplets.sos.wa.gov/myvote/myvote?language=#{lang}&Org=RocktheVote&firstname=#{fn}&lastName=#{ln}&DOB=#{dob}"
    else
      ""
    end    
  end
  
  
end
