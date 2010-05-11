begin
  require 'rocky_branding'
rescue LoadError => e
  $stderr.puts "Could not find branding package. Install the rocky_branding gem and try again."
  exit 1
end

namespace :branding do
  desc "Integrate branding package into app directory structure by creating symlinks for files and directories"
  task :symlink => :environment do
    RockyBranding.create_symlinks!
  end
end
