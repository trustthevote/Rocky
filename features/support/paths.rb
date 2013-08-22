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
module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in webrat_steps.rb
  #
  def path_to(page_name)
    case page_name
    
    when /the homepage/i
      root_path
    when /a new registration page for that partner/
      new_registrant_path(:partner=>Partner.last.id)
    when /a new registration page for partner="(\d)", source="(.+)" and tracking="(.+)"/
      new_registrant_path(:partner=>$1, :source=>$2, :tracking=>$3).to_s
    when /a new registration page for partner="(\d)"/
      new_registrant_path(:partner=>$1)
    when /a new registration page with collectemailaddress="(.+)"/
      new_registrant_path(:collectemailaddress=>$1)
    when /a new registration page/, /a new step 1 page/
      new_registrant_path
    when /new Spanish registration page/
      new_registrant_path(:locale => 'es')
    when /the step 1 page/
      registrant_path(@registrant)
    when /the step (\d) page/
      send("registrant_step_#{$1}_path", @registrant)
    when /the download page/
      registrant_download_path(@registrant)

    when /the Moose page/
      '/bullwinkle-floatbox.html'

    when /the register page/i
      new_partner_path
    when /the login page/i
      login_path
    # when /the partner password reset request page/i
    #   new_partner_password_path
    when /the partner dashboard/
      partner_path
    when /the admin dashboard/
      admin_partners_path
    when /the admin government partners page/
      admin_government_partners_path
    when /the registration page for that partner/
      "#{new_registrant_path}?partner=#{@partner.id}"
    when /the partner page for that partner/
      admin_partner_path(@partner || Partner.last)
    when /the partner edit page for that partner/
      edit_admin_partner_path(Partner.last)
    when /the partner edit page for the first partner/
      edit_admin_partner_path(Partner.first)

    # Add more mappings here.
    # Here is a more fancy example:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
