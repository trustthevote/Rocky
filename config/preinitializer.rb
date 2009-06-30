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
      #args += " --sudo" unless RUBY_PLATFORM =~ /mswin/

      # The 'install' method will auto-install gems as specified by the args and config
      GemInstaller.install(args)

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
