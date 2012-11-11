require 'highline/import'

module AktionCap
  class Tasks
    include Rake::DSL

    class << self
      def install_tasks
        new.install
      end
    end

    def install
      desc 'capify'
      task 'capify' do
        capfile = File.join(Dir.pwd, 'Capfile')
        File.open(capfile, 'w') do |f|
          f << <<FILE
load 'deploy'
load 'config/deploy'
FILE
        end

        application = ask("Enter the application name: ") {|q| q.default = File.basename(Dir.pwd)}
        scm = ask("Enter type of version control: ") {|q| q.default = "git"}
        repository = ask("Enter the git repository to deploy from: ") do |q|
          if scm == 'git'
            q.default = `git config --local remote.origin.url`.strip
          end
        end

        config_deploy = File.join(Dir.pwd, 'config', 'deploy.rb')
        File.open(config_deploy, 'w') do |f|
          f << <<FILE
set :stages %w(production staging)

require 'capistrano/ext/multistage'
require 'bundler/capistrano'
require 'rvm/capistrano'
require './config/boot'

ssh_options[:username] = 'deployer'
ssh_options[:forward_agent] = true

set :application, '#{application}'
set :repository, '#{repository}'
set :scm, :#{scm}
set :deploy_via, :remote_cache
set :deploy_to, "/var/www/\#{application}/\#{stage}"
set :rvm_type, :user
set :use_sudo, false

set :shared_symlinks, %w(config/database.yml)
set :tasks_for_rake, %w(db:migrate)

after 'deploy:update_code', 'deploy:create_shared_symlinks'
before 'deploy:create_symlink', 'deploy:run_rake_tasks'
after 'deploy', 'deploy:cleanup'
FILE
        end

        deploy_dir = File.join(Dir.pwd, 'config', 'deploy')
        Dir.mkdir(deploy_dir) unless Dir.exists?(deploy_dir)

        stages = ask("Enter the deployment stages(separate with commas): ") {|q| q.default = 'production'}.split(',')
        stages.each do |stage|
          deploy_file = File.join(Dir.pwd, 'config', 'deploy', "#{stage}.rb")
          server_hostname = ask("Enter the server hostname or IP: ") {|q| q.default = 'localhost'}
          server_port = ask("Enter the ssh port to connect to: ") do |q|
            if server_hostname == 'localhost'
              q.default = '2222'
            else
              q.default = '22'
            end
          end
          File.open(deploy_file, 'w') do |f|
            f << <<FILE
set :port, #{server_port}
set :server_hostname, '#{server_hostname}'
role :app, server_hostname
role :web, server_hostname
role :db,  server_hostname, primary: true
FILE
          end
        end
      end
    end
  end
end

AktionCap::Tasks.install_tasks
