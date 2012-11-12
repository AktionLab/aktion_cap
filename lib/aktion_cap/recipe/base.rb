def cset(name, *args, &block)
  set(name, *args, &block) unless exists? name
end

def append(name, values)
  if exists? name
    raise "set_append requires an array value to append to" unless fetch(name).is_a? Array
    set(name, fetch(name) + [values].flatten)
  else
    set(name, values)
  end
end

Capistrano::Configuration.instance.load do
  cset :shared_symlinks, []
  cset :tasks_for_rake, []

  namespace :deploy do
    task :create_shared_symlinks do
      run(shared_symlinks.map{|link| "ln -nfs #{shared_path}/#{link} #{release_path}/#{link}"}.join(' && '))
    end

    task :run_rake_tasks do
      run "cd #{release_path} && RAILS_ENV=#{stage} bundle exec rake #{tasks_for_rake.join(' ')}"
    end
  end
end

