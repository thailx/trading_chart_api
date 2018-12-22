# config valid for current version and patch releases of Capistrano
lock "~> 3.11.0"
ENV.update YAML.load_file(File.join(File.dirname(__FILE__), 'config.yml'))


# Change these
server ENV['TRADING_CHART_SERVER'], port: 22, roles: [:web, :app, :db], primary: true

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
set :linked_files, %w{config/config.yml config/database.yml config/master.key config/nginx.conf}
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
      master_key_path = File.join(File.dirname(__FILE__), 'master.key')
      nginx_conf_path = File.join(File.dirname(__FILE__), 'nginx.conf')
      upload! nginx_conf_path, "#{shared_path}/config/nginx.conf"
      upload! config_path, "#{shared_path}/config/config.yml"
      upload! database, "#{shared_path}/config/database.yml"
      upload! master_key_path, "#{shared_path}/config/master.key"

    end
  end

  desc 'Nginx'
  task :nginx do
    on roles(:all) do
      execute "sudo ln -nfs /var/www/trading_chart_api/shared/config/nginx.conf /etc/nginx/sites-enabled/trading_chart_api"
      execute "sudo service nginx restart"
    end
  end

  before 'deploy:check:linked_files', :copy
  after  :finishing, :cleanup
  after  :finishing, :nginx
  after  :finishing, :restart
end

