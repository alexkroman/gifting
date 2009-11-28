set :ssh_options, { :forward_agent => true }

set :application, "damncheaphotels.com"

role :app, "alex"
set :user, "alex"
set :keep_releases, 2
set :repository,  "ssh://alex/var/git/hotel.git"
set :scm, :git
set :branch, "master"
set :deploy_via, :remote_cache

set :deploy_to, "/var/www/#{application}"

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end

end