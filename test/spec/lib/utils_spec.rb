require 'spec'
require 'tempfile'
require "#{File.dirname(__FILE__)}/../../../server/files/usr/local/ec2onrails/lib/utils"

include Ec2onrails

describe Utils do

  describe "running a command" do
    it "should run command" do
      lambda {
        Utils.run('echo')
      }.should_not raise_error
    end

    it "should raise an error when false result" do
      lambda {
        Utils.run('bad-command-1234')
      }.should raise_error
    end
  end

  describe "finding rails environment" do
    it "should call script" do
      Utils.should_receive(:run).with('/usr/local/ec2onrails/bin/rails_env --application demo').and_return('production  ')

      Utils.rails_env('demo').should eql('production')
    end
  end

  describe "finding hostname" do
    it "should return result" do
      Utils.should_receive(:run).with('hostname -s').and_return('deathstar')
      
      Utils.hostname.should eql('deathstar')
    end

    it "should strip result" do
      Utils.should_receive(:run).with('hostname -s').and_return('  deathstar  ')
      
      Utils.hostname.should eql('deathstar')
    end
  end

  describe "generating from a template" do
    it "should create new file" do
      first_name = "John"
      last_name = "Smith"
      temp_path = Tempfile.new('greeting.out').path

      Utils.generate_template('greeting.txt.erb', temp_path, binding)

      File.read(temp_path).strip.should eql("Hello John Smith!")
    end
  end

end
