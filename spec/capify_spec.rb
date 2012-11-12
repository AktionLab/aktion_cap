require 'spec_helper'
require 'colored'

def string_similarity(str1, str2)
  str1.downcase!
  str2.downcase!
  pairs1 = (0..str1.length-2).map{|i| str1[i,2]}.reject{|pair| pair.include? " "}
  pairs2 = (0..str2.length-2).map{|i| str2[i,2]}.reject{|pair| pair.include? " "}
  union = pairs1.size + pairs2.size
  intersection = 0
  pairs1.each do |p1|
    0.upto(pairs2.size-1) do |i|
      if p1 === pairs2[i]
        intersection += 1
        pairs2.slice!(i)
        break
      end
    end
  end
  (2.0 * intersection) / union
end

RSpec::Matchers.define :contain_content do |expected_line|
  match do |file|
    file = File.open(file) if file.is_a? String
    file.lines.any? {|l| l == "#{expected_line}\n"}
  end

  failure_message_for_should do |file|
    file = File.open(file) if file.is_a? String
    lines = file.lines.to_a
    best_match = [string_similarity(expected_line, lines.first), lines.first]
    lines[1..-1].each do |l|
      score = string_similarity(expected_line, l)
      best_match = [score,l] if score > best_match[0]
    end
    "Expected:\n#{expected_line}\nClosest match:\n#{best_match[1].yellow}\n#{lines.map(&:blue).join('')}"
  end
end

RSpec::Matchers.define :be_a_file_that_exists do
  match do |filename|
    File.exists?(filename)
  end

  failure_message_for_should do |filename|
    "expected #{filename} to exist"
  end

  failure_message_for_should_not do |filename|
    "expected #{filename} to not exist"
  end
end

describe 'capify' do
  context 'default' do
    before(:each) do
      `cd dummy && cat ../spec/fixtures/default_capify_responses | rake clean capify`
    end

    describe 'dummy/Capfile' do
      it { should be_a_file_that_exists }
    end

    describe "dummy/config/deploy.rb" do
      it { should be_a_file_that_exists }
      it { should contain_content "set :stages, %w(production)" }
      it { should contain_content "set :application, 'dummy'" }
      it { should contain_content "set :repository, '#{`git config --local remote.origin.url`.strip}'" }
      it { should contain_content "set :scm, :git" }
      it { should contain_content "ssh_options[:username] = 'deployer'" }
      it { should contain_content "require 'aktion_cap/recipe/base'" }
      it { should contain_content "require 'aktion_cap/recipe/database'" }
      it { should contain_content "require 'aktion_cap/recipe/nginx'" }
      it { should contain_content "require 'aktion_cap/recipe/unicorn'" }
    end

    describe 'dummy/config/deploy/production.rb' do
      it { should be_a_file_that_exists }
      it { should contain_content "set :port, 2222" }
      it { should contain_content "set :server_hostname, 'localhost'" }
    end

    describe 'dummy/config/nginx_production.conf' do
      it { should be_a_file_that_exists }
    end
  end

  context 'custom' do
    before(:each) do
      `cd dummy && cat ../spec/fixtures/custom_capify_responses | rake clean capify`
    end

    describe 'dummy/config/deploy.rb' do
      it { should be_a_file_that_exists }
      it { should contain_content "set :stages, %w(staging production)" }
      it { should contain_content "set :application, 'custom_application'" }
      it { should contain_content "set :repository, 'git@github.com:someone/custom_application'" }
      it { should contain_content "ssh_options[:username] = 'www-data'" }
    end

    describe 'dummy/config/deploy/production.rb' do
      it { should be_a_file_that_exists }
      it { should contain_content "set :port, 2424" }
      it { should contain_content "set :server_hostname, 'www.customapp.com'" }
    end

    describe 'dummy/config/deploy/staging.rb' do
      it { should be_a_file_that_exists }
      it { should contain_content "set :port, 2323" }
      it { should contain_content "set :server_hostname, 'staging.customapp.com'" }
    end

    describe 'dummy/config/nginx_production.conf' do
      it { should be_a_file_that_exists }
    end

    describe 'dummy/config/nginx_staging.conf' do
      it { should be_a_file_that_exists }
    end
  end
end
