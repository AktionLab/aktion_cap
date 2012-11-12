Capistrano::Configuration.instance.load do
  append :shared_symlinks, 'config/unicorn.rb'

  namespace :deploy do
    %w(start stop restart).each do |action|
      task(action, except: { no_release: true }) { run "cd #{current_path} && RAILS_ENV=#{stage} script/unicorn #{action}" }
    end
  end
end
