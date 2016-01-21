# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'curago'
set :repo_url, 'git@github.com:WeezLabs/Curago.git'

set :linked_files, ['config/database.yml']
set :linked_dirs, %w(log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system)

set :ssh_options, {forward_agent: true}
set :user , 'deployer'
set :deploy_to, "/home/#{fetch :user}/apps/#{fetch :application}"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, true


namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
