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
############# GemInstaller Rails Preinitializer - see http://geminstaller.rubyforge.org

# This file should be required in your Rails config/preinitializer.rb for Rails >= 2.0,
# or required in config/boot.rb before initialization for Rails < 2.0.  For example:
#   require 'geminstaller_rails_preinitializer'
#
# If you require a different geminstaller configuration, copy this file into your Rails app,
# modify it, and require your customized version.  For example:
#   require "#{File.expand_path(RAILS_ROOT)}/config/custom_geminstaller_rails_preinitializer.rb"

require "rubygems" 
require "geminstaller" 

module GemInstallerRailsPreinitializer
  class << self
    def preinitialize
      args = ''

      # Specify --geminstaller-output=all and --rubygems-output=all for maximum debug logging
      # args += ' --geminstaller-output=all --rubygems-output=all'

      # The 'exceptions' flag determines whether errors encountered while running GemInstaller
      # should raise exceptions (and abort Rails), or just return a nonzero return code
      args += " --exceptions" 

      # This will use sudo by default on all non-windows platforms, but requires an entry in your
      # sudoers file to avoid having to type a password.  It can be omitted if you don't want to use sudo.
      # See http://geminstaller.rubyforge.org/documentation/documentation.html#dealing_with_sudo
      # Note that environment variables will NOT be passed via sudo!
      args += " --sudo" unless RUBY_PLATFORM =~ /mswin/

      # The 'install' method will auto-install gems as specified by the args and config
      if ENV['IS_CI_BOX']
        # you can change the output defaults under cruise if you want
        # args += " --geminstaller-output=all --rubygems-output=all"

        # Only install gems on Rails startup if we are on CI.  In local dev environment, this avoids having to type the sudo
        # password on every app/test run, and on deployment you should be calling this before app startup as a capistrano task.
        GemInstaller.install(args)
      end

      # The 'autogem' method will automatically add all gems in the GemInstaller config to your load path,
      # using the rubygems 'gem' method.  Note that only the *first* version of any given gem will be loaded.
      GemInstaller.autogem(args)
    end
  end
end

# Attempt to prevent GemInstaller from running twice, but won't work if it is executed
# in a separate interpreter (like rake tests)
GemInstallerRailsPreinitializer.preinitialize unless $geminstaller_initialized
$geminstaller_initialized = true
