class NV < StateCustomization
  def online_reg_url(registrant)
    root_url ="https://nvsos.gov/sosvoterservices/Registration/step1.aspx?source=rtv&utm_source=rtv&utm_medium=rtv&utm_campaign=rtv"
    return root_url if registrant.nil?
    fn = CGI.escape registrant.first_name.to_s
    mn = CGI.escape registrant.middle_name.to_s
    ln = CGI.escape registrant.last_name.to_s
    sf = CGI.escape registrant.name_suffix.to_s
    zip = CGI.escape registrant.home_zip_code.to_s
    lang = registrant.locale.to_s
    "#{root_url}&fn=#{fn}&mn=#{mn}&ln=#{ln}&lang=#{lang}&zip=#{zip}&sf=#{sf}"
  end
end