class WA < StateCustomization
  def online_reg_url(registrant)
    root_url ="https://weiapplets.sos.wa.gov/myvote/myvote"
    return root_url if registrant.nil?
    fn = CGI.escape registrant.first_name.to_s
    ln = CGI.escape registrant.last_name.to_s
    dob= CGI.escape registrant.form_date_of_birth.to_s.gsub('-','/')
    lang= registrant.locale
    "#{root_url}?language=#{lang}&Org=RocktheVote&firstname=#{fn}&lastName=#{ln}&DOB=#{dob}"
  end
end