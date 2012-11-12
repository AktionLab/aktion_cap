Capistrano::Configuration.instance.load do
  namespace :nginx do
    task :config do
      remote_nginx_conf = "/etc/nginx/sites-enabled/#{application}_#{stage}"
      run "sudo rm -f #{remote_nginx_conf} && sudo ln -nfs #{release_path}/config/nginx_#{stage}.conf #{remote_nginx_conf}"
    end

    %w(start stop restart reload).each do |action|
      task(action) { "sudo /etc/init.d/nginx #{action}" }
    end
  end
end
