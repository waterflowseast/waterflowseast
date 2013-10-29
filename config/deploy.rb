require 'rvm/capistrano'
require 'bundler/capistrano'
require 'sidekiq/capistrano'

set :whenever_command, "bundle exec whenever"
require 'whenever/capistrano'

server '96.126.112.59', :web, :app, :db, primary: true

set :application, "waterflowseast"
set :user, "deployer"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

set :scm, "git"
set :repository, "git@github.com:waterflowseast/#{application}.git"
set :branch, "master"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after "deploy", "deploy:cleanup" # keep only the last 5 releases

namespace :deploy do
  desc "Zero-downtime restart of Unicorn"
  task :restart, roles: :app, except: { no_release: true } do
    run "kill -s USR2 `cat #{shared_path}/pids/unicorn.pid`"
  end

  desc "Start unicorn"
  task :start, roles: :app, except: { no_release: true } do
    run "cd #{current_path} ; bundle exec unicorn_rails -c config/unicorn.rb -D -E production"
  end

  desc "Stop unicorn"
  task :stop, roles: :app, except: { no_release: true } do
    run "kill -s QUIT `cat #{shared_path}/pids/unicorn.pid`"
  end

  task :setup_config, roles: :app do
    run "#{sudo} ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
    run "mkdir -p #{shared_path}/config/initializers"
    put File.read("config/database.yml"), "#{shared_path}/config/database.yml"
    put File.read("config/initializers/secret_token.rb"), "#{shared_path}/config/initializers/secret_token.rb"
  end
  after "deploy:setup", "deploy:setup_config"

  task :update_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/initializers/secret_token.rb #{release_path}/config/initializers/secret_token.rb"
  end
  after "deploy:finalize_update", "deploy:update_config"

  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run `git push` to sync changes."
      exit
    end
  end
  before "deploy", "deploy:check_revision"
end
