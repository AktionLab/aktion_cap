require 'colored'
require 'fileutils'

namespace :test do
  desc 'Setup the test environment'
  task :setup => %w(setup:rails setup:vagrant)

  desc 'Teardown the test enviornment'
  task :clean => %w(clean:rails clean:vagrant)

  namespace :setup do
    desc 'Setup the dummy rails application'
    task :rails do
      puts 'Setting up the dummy rails application'.green
      pipe = IO.popen('rails new dummy -m lib/dummy_rails_template.rb -T -G -O -S -J --skip-gemfile --skip-bundle')
      while line = pipe.gets
        puts line
      end
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
      FileUtils.rm_rf './dummy'
    end

    desc 'Teardown the vagrant deployment VM'
    task :vagrant do
      puts 'Tearing down the vagrant deployment VM'.green
    end
  end
end
