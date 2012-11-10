require 'colored'

namespace :test do
  desc 'Setup the test environment'
  task :setup => %w(setup:rails setup:vagrant)

  desc 'Teardown the test enviornment'
  task :clean => %w(clean:rails clean:vagrant)

  namespace :setup do
    desc 'Setup the dummy rails application'
    task :rails do
      puts 'Setting up the dummy rails application'.green
    end

    desc 'Setup the vagrant deployment VM'
    task :vagrant do
      puts 'Setting up the vagrant deployment VM'.green
    end
  end

  namespace :clean do
    desc 'Teardown the dummy rails application'
    task :rails do
      puts 'Tearing down the dummy rails application'.green
    end

    desc 'Teardown the vagrant deployment VM'
    task :vagrant do
      puts 'Tearing down the vagrant deployment VM'.green
    end
  end
end
