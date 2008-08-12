#    This file is part of EC2 on Rails.
#    http://rubyforge.org/projects/ec2onrails/
#
#    Copyright 2007 Paul Dowman, http://pauldowman.com/
#
#    EC2 on Rails is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    EC2 on Rails is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'rubygems'
require 'erb'
require 'pathname'
require 'fileutils'
require "#{File.dirname(__FILE__)}/utils"

module Ec2onrails
  class AppHelper
    ROOT_PATH = '/mnt'
    APACHE_PATH = '/etc/apache2'
    MONGREL_INSTANCES = 6
    BALANCE_MANAGER_START_PORT = 8080
    START_CLUSTER_PORT = 8000
    CLUSTER_PORT_OFFSET = 100
    USER_NAME = 'app' # TODO: need to create a user for each app to be more secure
    TEMPLATE_PATH = "#{File.dirname(__FILE__)}/../templates"

    attr_accessor :name
    attr_reader :application_path

    def initialize(name)
     @name = name
     @application_path = "#{ROOT_PATH}/#{@name}"
    end

    def create_directory
      # make root dir 
      Dir.mkdir application_path
      
      # create subdirectories 
      ['releases', 'shared', 'shared/log', 'shared/pids'].each do |dir|
        Dir.mkdir "#{application_path}/#{dir}"
      end

      # permissions
      FileUtils.chown_R(USER_NAME, USER_NAME, application_path) 
    end

    # domain string is used by erb template
    def create_apache_files(domain_string)
     base_path = "#{APACHE_PATH}/sites-available"
     
     # create the main config file 
     Utils.generate_template("#{TEMPLATE_PATH}/application.erb", "#{base_path}/#{name}", binding)
 
     # create a config with common setup
     Utils.generate_template("#{TEMPLATE_PATH}/common.erb", "#{base_path}/#{name}.common", binding)
 
     # create empty config file for custom configuration
     FileUtils.touch("#{base_path}/#{name}.custom")
 
     # link the folders
     File.symlink("#{base_path}/#{name}", "#{APACHE_PATH}/sites-enabled/#{sprintf("%03d",application_count)}-#{name}")
    end

    # rails_env is passed to the template
    def create_mongrel_files(rails_env)
      base_path = "#{APACHE_PATH}/conf.d"
      start_port = (START_CLUSTER_PORT + (application_count*CLUSTER_PORT_OFFSET))
      ports = (start_port..(start_port+MONGREL_INSTANCES-1))
 
      Utils.generate_template("#{TEMPLATE_PATH}/mongrel_cluster.yml.erb", 
                              "/etc/mongrel_cluster/#{name}.yml", binding)

      Utils.generate_template("#{TEMPLATE_PATH}/proxy_cluster.conf.erb", 
                              "#{base_path}/#{name}.proxy_cluster.conf", binding)

      Utils.generate_template("#{TEMPLATE_PATH}/proxy_frontend.conf.erb", 
                              "#{base_path}/#{name}.proxy_frontend.conf", binding)
    end

    def destroy_directory
      FileUtils.rm_rf application_path 
    end

    def destroy_apache_files
      FileUtils.rm("#{APACHE_PATH}/sites-enabled/#{sprintf("%03d", application_index)}-#{name}")
      FileUtils.rm("#{APACHE_PATH}/sites-available/#{name}")
      FileUtils.rm("#{APACHE_PATH}/sites-available/#{name}.common")
      FileUtils.rm("#{APACHE_PATH}/sites-available/#{name}.custom")
    end
 
    def destroy_mongrel_files
      base_path = "#{APACHE_PATH}/conf.d"
 
      FileUtils.rm("/etc/mongrel_cluster/#{name}.yml")
      FileUtils.rm("#{base_path}/#{name}.proxy_cluster.conf")
      FileUtils.rm("#{base_path}/#{name}.proxy_frontend.conf")
    end

  private

    def application_index
      Dir.glob("#{APACHE_PATH}/sites-enabled/*").each do |file|
        name = Pathname.new(file).basename.to_s
        match = name.match(/^(\d+)-(.*)$/)

        if match && match[1] == name
          return match[0].to_i
          break
        end
      end
      raise 'Application not found'
    end

    def application_count
      Dir.glob("#{APACHE_PATH}/sites-enabled/*").length
    end

  end
end
