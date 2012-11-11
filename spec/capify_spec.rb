require 'spec_helper'
require 'open3'

def capify
  `cat test.txt | rake capify`
end

describe 'capify' do
  context 'default' do
    before(:all) do
      `cd dummy && cat test.txt | rake cdean capify`
    end

    it "create a Capfile" do
      File.exists?('dummy/Capfile').should be_true
    end

    context "config/deploy.rb" do
      subject { File.open('dummy/config/deploy.rb') }

      it 'should exist' do
        File.exists?(subject).should be_true
      end

      it 'should set the application name to the directory name by default' do
        subject.lines.any? {|l| l == "set :application, 'dummy'\n"}.should be_true
      end

      it 'should set the repository location to the git remote origin' do
        subject.lines.any? {|l| l == "set :repository, 'git@github.com:AktionLab/aktion_cap'\n"}.should be_true
      end

      it 'should set the scm to git by default' do
        subject.lines.any? {|l| l == "set :scm, :git\n"}.should be_true
      end
    end

    context 'config/deploy/production.rb' do
      subject { File.open('dummy/config/deploy/production.rb')}

      it 'should exist' do
        File.exists?(subject).should be_true
      end

      it 'should set the port' do
        subject.lines.any? {|l| l == "set :port, 2222\n"}.should be_true
      end

      it 'should set the hostname' do
        subject.lines.any? {|l| l == "set :server_hostname, 'localhost'\n"}.should be_true
      end
    end
  end
end
