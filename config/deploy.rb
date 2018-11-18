# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"

ENV.update YAML.load_file(File.join(File.dirname(__FILE__), 'config.yml'))

# Change these
server ENV['TRADING_CHART_SERVER'], user: ENV['TRADING_CHART_USER_DEPLOY'], port: 22, roles: [:web, :app, :db], primary: true

set :stages, %w(production staging)

set :repo_url,        ENV['TRADING_CHART_REPO_URL']
set :application,     ENV['TRADING_CHART_APP_NAME']
set :user,            ENV['TRADING_CHART_USER_DEPLOY']
set :puma_threads,    [4, 16]
# Config ruby version
set :rbenv_type, :user # or :system, depends on your rbenv setup

set :use_sudo,        false
set :deploy_via,      :remote_cache
set :deploy_to,       "/var/www/#{fetch(:application)}"
# set :deploy_to,       "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :puma_conf, "#{shared_path}/puma.rb"
set :ssh_options,     {
    forward_agent: true,
    user: fetch(:user),
    keys: [ENV['TRADING_CHART_PUBLIC_KEY']],
    auth_methods: %w(publickey)
}
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord

set :branch, ENV['TRADING_CHART_REPO_BRANCH']
set :keep_releases, 5

## Linked Files & Directories (Default None):
set :linked_files, %w{config/config.yml config/secrets.yml config/database.yml}
set :linked_dirs,  %w{log tmp vendor public}

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

namespace :deploy do
  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Copy files'
  task :copy do
    on roles(:all) do
      database = File.join(File.dirname(__FILE__), 'database.yml')
      config_path = File.join(File.dirname(__FILE__), 'config.yml')
      upload! config_path, "#{shared_path}/config/config.yml"
      upload! database, "#{shared_path}/config/database.yml"
    end
  end

  desc 'Nginx'
  task :nginx do
    on roles(:all) do
      execute "sudo service nginx restart"
    end
  end

  before 'deploy:check:linked_files', :copy
  after  :finishing, :cleanup
  after  :finishing, :nginx
  after  :finishing, :restart
end

