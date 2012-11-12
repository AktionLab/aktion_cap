require 'highline/import'

module AktionCap
  class Tasks
    include Rake::DSL

    class << self
      def install_tasks
        new.install
      end
    end

    def prompts_for_capify
      options = {}
      options[:application] = ask("Enter the application name: ") {|q| q.default = File.basename(Dir.pwd)}
      options[:scm] = ask("Enter type of version control: ") {|q| q.default = "git"}
      options[:repository] = ask("Enter the git repository to deploy from: ") do |q|
        if options[:scm] == 'git'
          q.default = `git config --local remote.origin.url`.strip
        end
      end
      options[:ssh_user] = ask("Enter the ssh username to deploy with: ") {|q| q.default = 'deployer'}
      options[:stages] = ask("Enter the deployment stages(separate with commas): ") {|q| q.default = 'production'}.split(',').map(&:to_sym)
      options[:stages].each do |stage|
        say("\nConfigure #{stage.to_s}:")
        options[stage] = {}
        options[stage][:server_hostname] = ask("  Enter the server hostname or IP: ") {|q| q.default = 'localhost'}
        options[stage][:server_port] = ask("  Enter the ssh port to connect to: ", Integer) do |q|
          if options[stage][:server_hostname] == 'localhost'
            q.default = '2222'
          else
            q.default = '22'
          end
        end
      end
      options
    end

    def write_capfile
      File.open('Capfile', 'w') do |file|
        file << <<-FILE
load 'deploy'
load 'config/deploy'
        FILE
      end
    end

    def write_config_deploy(opts)
      File.open('config/deploy.rb', 'w') do |file|
        file << <<-FILE
set :stages, %w(#{opts[:stages].map(&:to_s).join(' ')})

require 'capistrano/ext/multistage'
require 'bundler/capistrano'
require 'rvm/capistrano'
require './config/boot'
require 'aktion_cap/recipe/base'
require 'aktion_cap/recipe/database'
require 'aktion_cap/recipe/nginx'
require 'aktion_cap/recipe/unicorn'

ssh_options[:username] = '#{opts[:ssh_user]}'
ssh_options[:forward_agent] = true

set :application, '#{opts[:application]}'
set :repository, '#{opts[:repository]}'
set :scm, :#{opts[:scm]}
set :deploy_via, :remote_cache
set(:deploy_to) {"/var/www/\#{application}/\#{stage}"}
set :rvm_type, :user
set :use_sudo, false

set :shared_symlinks, %w(config/database.yml)
set :tasks_for_rake, %w(db:migrate)

after  'deploy:update_code',    'deploy:create_shared_symlinks'
before 'deploy:create_symlink', 'deploy:run_rake_tasks'
before 'deploy:restart',        'nginx:config'
after  'deploy',                'deploy:cleanup'
        FILE
      end
    end

    def write_stage_config_deploy(stage, opts)
      File.open("config/deploy/#{stage.to_s}.rb", 'w') do |file|
        file << <<-FILE
set :port, #{opts[stage][:server_port]}
set :server_hostname, '#{opts[stage][:server_hostname]}'
role :app, server_hostname
role :web, server_hostname
role :db,  server_hostname, primary: true
        FILE
      end
    end

    def write_nginx(stage, opts)
      File.open("config/nginx_#{stage.to_s}.conf", 'w') do |file|
        file << <<-FILE
upstream #{opts[:application]}_#{stage.to_s} {
  server unix:/tmp/unicorn-#{opts[:application]}_#{stage.to_s}.sock fail_timeout=0;
}

server {
  listen 80;

  server_name #{opts[stage][:server_hostname]};

  root /var/www/#{opts[:application]}/#{stage.to_s}/current/public;
  access_log /var/log/nginx/#{opts[:application]}_#{stage.to_s}-access.log;
  error_log /var/log/nginx/#{opts[:application]}_#{stage.to_s}-error.log;

  location ~ ^/assets/ {
    gzip_static on;
    expires max;
    add_header Cache-Control public;
  }

  location {
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect off;

    if (!-f $request_filename) {
      proxy_pass http://#{opts[:application]}_#{stage.to_s};
      break;
    }
  }

  error_page 404 /404.html;
  error_page 500 502 503 504 /500.html;
}
        FILE
      end
    end

    def install
      desc 'capify'
      task 'capify' do
        opts = prompts_for_capify
        Dir.mkdir('config/deploy') unless Dir.exists?('config/deploy')
        write_capfile
        write_config_deploy opts
        opts[:stages].each do |stage|
          write_stage_config_deploy(stage, opts)
          write_nginx(stage, opts)
        end
      end
    end
  end
end

AktionCap::Tasks.install_tasks
