require 'rocky_branding'

namespace :branding do
  desc "Integrate branding package into app directory structure by creating symlinks for files and directories"
  task :symlink => :environment do
    RockyBranding.create_symlinks!
  end
end
