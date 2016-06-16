# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'curago'
set :repo_url, 'git@github.com:WeezLabs/Curago.git'

set :linked_files, ['config/database.yml']
set :linked_dirs, %w(log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system)

set :ssh_options, {forward_agent: true}
# set :user , 'deployer'
set :user, 'koryushka_guest'
set :deploy_to, "/home/#{fetch :user}/apps/#{fetch :application}"

#nginx configuration
set :nginx_roles, :app

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, true


namespace :deploy do

  # after :deploy, 'nginx:restart'
  after :deploy, 'sidekiq:start'
end
