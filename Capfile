# Load DSL and Setup Up Stages
require 'capistrano/setup'
require 'capistrano/deploy'


# require 'capistrano/rails'
require 'capistrano/rails/collection'
require 'capistrano/bundler'
require 'capistrano/rails/migrations'
require 'capistrano/rbenv'
require 'capistrano/puma'
require 'capistrano/scm/git'
require 'capistrano/sidekiq'
# require 'capistrano/sidekiq/monit' #to require monit tasks # Only for capistrano3

install_plugin Capistrano::SCM::Git
install_plugin Capistrano::Puma

# Loads custom tasks from `lib/capistrano/tasks' if you have any defined.
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }