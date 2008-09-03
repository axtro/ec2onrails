require 'spec'
require "#{File.dirname(__FILE__)}/../../../server/files/usr/local/ec2onrails/lib/app_helper"

include Ec2onrails

describe AppHelper do
  before :each do
    @helper = AppHelper.new('demo')
  end

  describe "creating directory" do
    it "should create directories" do
       Dir.should_receive(:mkdir).with('/mnt/demo')
       Dir.should_receive(:mkdir).with('/mnt/demo/releases')
       Dir.should_receive(:mkdir).with('/mnt/demo/shared')
       Dir.should_receive(:mkdir).with('/mnt/demo/shared/log')
       Dir.should_receive(:mkdir).with('/mnt/demo/shared/pids')
       FileUtils.should_receive(:chown_R).with('app', 'app', '/mnt/demo')
      
       @helper.create_directory
    end
  end

  describe "creating apache files" do
    it "should create apache files" do
      Utils.should_receive(:generate_template).
        with("#{AppHelper::TEMPLATE_PATH}/application.erb", "/etc/apache2/sites-available/demo", anything())  

      Utils.should_receive(:generate_template).
        with("#{AppHelper::TEMPLATE_PATH}/common.erb", "/etc/apache2/sites-available/demo.common", anything())

      FileUtils.should_receive(:touch).with("/etc/apache2/sites-available/demo.custom")
      File.should_receive(:symlink).with("/etc/apache2/sites-available/demo", "/etc/apache2/sites-enabled/001-demo")

      @helper.create_apache_files('test.com')
    end
  end

  describe "creating mongrel configuration" do
    it "should create mongrel files" do

      Utils.should_receive(:generate_template).with("#{AppHelper::TEMPLATE_PATH}/mongrel_cluster.yml.erb",
        "/etc/mongrel_cluster/demo.yml", anything())

      Utils.should_receive(:generate_template).with("#{AppHelper::TEMPLATE_PATH}/proxy_cluster.conf.erb",
        "/etc/apache2/conf.d/demo.proxy_cluster.conf", anything())

      Utils.should_receive(:generate_template).with("#{AppHelper::TEMPLATE_PATH}/proxy_frontend.conf.erb",
        "/etc/apache2/conf.d/demo.proxy_frontend.conf", anything())

      @helper.create_mongrel_files('production')
    end
  end
  
  describe "creating monit configuration" do
    it "should create monitrc" do
      Utils.should_receive(:generate_template).with("#{AppHelper::TEMPLATE_PATH}/monitrc.erb",
        "/etc/monit/demo.monitrc", anything())

      @helper.create_monitrc_file
    end
  end
  
  describe "destroying directory" do
     it "should destroy directories" do
       FileUtils.should_receive(:rm_rf).with('/mnt/demo')

       @helper.destroy_directory
     end
  end

  describe "destroying apache files" do
    it "should destroy apache files" do
      FileUtils.should_receive(:rm).with("/etc/apache2/sites-enabled/002-demo")
      FileUtils.should_receive(:rm).with("/etc/apache2/sites-available/demo")
      FileUtils.should_receive(:rm).with("/etc/apache2/sites-available/demo.common")
      FileUtils.should_receive(:rm).with("/etc/apache2/sites-available/demo.custom")

      Dir.should_receive(:glob).with('/etc/apache2/sites-enabled/*').and_return(['003-demo-skip', '002-demo'])

      @helper.destroy_apache_files
    end
  end

  describe "destroying mongrel configuration" do
    it "should destroy mongrel files" do
       FileUtils.should_receive(:rm).with("/etc/mongrel_cluster/demo.yml")
       FileUtils.should_receive(:rm).with("/etc/apache2/conf.d/demo.proxy_cluster.conf")
       FileUtils.should_receive(:rm).with("/etc/apache2/conf.d/demo.proxy_frontend.conf")

       @helper.destroy_mongrel_files
    end
  end

  describe "destroying monitrc configuration" do
    it "should destroy monitrc" do
      FileUtils.should_receive(:rm).with("/etc/monit/demo.monitrc")

      @helper.destroy_monitrc_file
    end
  end
end
