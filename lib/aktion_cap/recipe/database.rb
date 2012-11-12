Capistrano::Configuration.instance.load do
  append :shared_symlinks, 'config/database.yml'
  append :tasks_for_rake, 'db:migrate'
end
