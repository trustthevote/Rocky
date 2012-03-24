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
set :application, "rocky"
set :repository,  "git@git.osuosl.org:rocky"

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

set :stages, Dir["config/deploy/*"].map {|stage|File.basename(stage, '.rb')}
set :default_stage, "production"
require 'capistrano/ext/multistage'

set :scm, "git"
set :user, "rocky"
set :deploy_via, :remote_cache
set :branch, (rev rescue "master")    # cap deploy -Srev=[branch|tag|SHA1]

set :group_writable, false
set :use_sudo, false


# before "deploy", "deploy:stop_workers"
after "deploy:update_code", "deploy:symlink_configs", "deploy:symlink_pdf"

#No more geminstaller - bundler [AMM]
#after "deploy:symlink_configs", "deploy:geminstaller"
before "deploy:restart", "deploy:symlink_branding", "deploy:import_states_csv"   # runs after migrations when migrating
after "deploy:restart", "deploy:run_workers"
after "deploy", "deploy:cleanup"

namespace :deploy do
  # no more geminstaller - bundler [AMM]
  # desc "run GemInstaller"
  # task :geminstaller, :roles => [:app, :util] do
  #   sudo "geminstaller -c #{current_release}/config/geminstaller.yml"
  # end

  # try doing all rakes with bundle exec ? [AMM]
  desc "import states.csv data"
  task :import_states_csv, :roles => [:app] do
    run <<-CMD
      cd #{latest_release} &&
      bundle exec rake import:states CSV_FILE=db/bootstrap/import/states.csv
    CMD
  end

  desc "Link the database.yml and mongrel_cluster.yml files into the current release path."
  task :symlink_configs, :roles => [:app, :util], :except => {:no_release => true} do
    run <<-CMD
      cd #{latest_release} &&
      ln -nfs #{shared_path}/config/database.yml #{latest_release}/config/database.yml
    CMD
    run <<-CMD
      cd #{latest_release} &&
      ln -nfs #{shared_path}/config/newrelic.yml #{latest_release}/config/newrelic.yml
    CMD
    run <<-CMD
      cd #{latest_release} &&
      ln -nfs #{shared_path}/config/initializers/hoptoad.rb #{latest_release}/config/initializers/hoptoad.rb
    CMD
  end

  desc "Install the branding gem from a local .gem file onto all servers"
  task :install_branding, :roles => [:app, :util] do
    local_path = ENV['GEM_FILE']
    unless local_path
      puts "You must provide a gem to upload and install in GEM_FILE env var."
      exit 1
    end
    remote_path = File.join("/tmp", File.basename(local_path))
    top.upload local_path, remote_path, :via => :scp
    sudo "gem install #{remote_path}"
  end

  desc "Link the files/directories in the branding gem into the app directory structure"
  task :symlink_branding, :roles => [:app, :util], :except => {:no_release => true} do
    run "cd #{latest_release} && rake branding:symlink"
  end

  desc "Link the pdf dir to /data/rocky/pdf"
  task :symlink_pdf, :roles => [:util], :except => {:no_release => true} do
    run <<-CMD
      cd #{latest_release} &&
      rm -rf pdf &&
      ln -nfs /data/rocky/html pdf
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

  desc "Run (or restart) worker processes on util server"
  task :run_workers, :roles => :util do
    run "cd #{latest_release} && ruby script/rocky_runner stop"
    run "cd #{latest_release} && ruby script/rocky_pdf_runner stop"
    # nasty hack to make sure it stops
    run "pkill -f com.pivotallabs.rocky.PdfServer" rescue nil
    sleep 5 
    run "cd #{latest_release} && ruby script/rocky_pdf_runner start"
    run "cd #{latest_release} && ruby script/rocky_runner start"
    unset(:latest_release)
  end

  desc "Stop worker processes on util server"
  task :stop_workers, :roles => :util do
    run "cd #{latest_release} && ruby script/rocky_runner stop"
    run "cd #{latest_release} && ruby script/rocky_pdf_runner stop"
    # nasty hack to make sure it stops
    run "pkill -f com.pivotallabs.rocky.PdfServer" rescue nil
    unset(:latest_release)
  end
end

namespace :import do
  desc "Upload state data from CSV_FILE and restart server"
  task :states, :roles => :app do
    local_path = ENV['CSV_FILE'] || 'states.csv'
    remote_dir = File.join(shared_path, "uploads")
    remote_path = File.join(remote_dir, File.basename(local_path))
    run "mkdir -p #{remote_dir}"
    top.upload local_path, remote_path, :via => :scp
    run "cd #{current_path} && rake import:states CSV_FILE=#{remote_path}"
    find_and_execute_task "deploy:restart"
  end
end


Dir[File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'hoptoad_notifier-*')].each do |vendored_notifier|
  $: << File.join(vendored_notifier, 'lib')
end

require 'hoptoad_notifier/capistrano'
