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
      '/bullwinkle.html'

    when /the register page/i
      new_partner_path
    when /the login page/i
      login_path
    # when /the partner password reset request page/i
    #   new_partner_password_path
    when /the partner dashboard/
      partner_path


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
