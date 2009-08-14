set :application, "rocky"
set :repository,  "git@github.com:pivotal/rocky.git"

# If you have previously been relying upon the code to start, stop 
# and restart your mongrel application, or if you rely on the database
# migration code, please uncomment the lines you require below

# If you are deploying a rails app you probably need these:

# load 'ext/rails-database-migrations.rb'
# load 'ext/rails-shared-directories.rb'

# There are also new utility libaries shipped with the core these 
# include the following, please see individual files for more
# documentation, or run `cap -vT` with the following lines commented
# out to see what they make available.

# load 'ext/spinner.rb'              # Designed for use with script/spin
# load 'ext/passenger-mod-rails.rb'  # Restart task for use with mod_rails
# load 'ext/web-disable-enable.rb'   # Gives you web:disable and web:enable

set :deploy_to, "/var/www/register.rockthevote.com/rocky"

role :web,  "hood.osuosl.org"
role :app,  "hood.osuosl.org"
role :util, "rainier.osuosl.org"
role :db,   "hood.osuosl.org", :primary => true

set :scm, "git"
set :user, "rocky"
set :branch, "master"

set :deploy_via, :remote_cache

set :use_sudo, false

after "deploy:update_code", "deploy:symlink_configs"
after "deploy:symlink_configs", "deploy:geminstaller" 

namespace :deploy do
  desc "run GemInstaller"
  task :geminstaller, :roles => [:app, :util] do
    sudo "geminstaller -c #{current_release}/config/geminstaller.yml"
  end

  desc "Link the database.yml and mongrel_cluster.yml files into the current release path."
  task :symlink_configs, :roles => [:app, :util], :except => {:no_release => true} do
    run <<-CMD
      cd #{latest_release} &&
      ln -nfs #{shared_path}/config/database.yml #{latest_release}/config/database.yml
    CMD
  end

  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end
