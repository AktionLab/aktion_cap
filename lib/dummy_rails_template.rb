application_name = "dummy"

run "echo > Gemfile"

add_source :rubygems
gem 'rails'
gem 'aktion_cap', path: '..'

run "bundle install"

run "rm public/index.html"
run "rm -rf doc"
run "rm README.rdoc"
run "rm -rf app/assets"

rakefile 'clean.rake' do
  <<-TASK
    require 'fileutils'

    task :clean do
      files = %w(Capfile config/deploy.rb config/deploy/staging.rb config/deploy/production.rb)
      files.map{|f| File.join(Dir.pwd, f)}.each{|f| FileUtils.rm_f f}
    end
  TASK
end

