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
    MONGREL_INSTANCES = 4
    BALANCE_MANAGER_START_PORT = 8090
    START_CLUSTER_PORT = 8100
    CLUSTER_PORT_OFFSET = 100
    USER_NAME = 'app' # TODO: need to create a user for each app to be more secure

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

    def create_apache_files
     base_path = "#{APACHE_PATH}/sites-available"
     index = 0
   
     # determine last number  
     Dir.glob("#{APACHE_PATH}/sites-enabled/*").each do |file|
       match = Pathname.new(file).basename.to_s.match(/\d+/)
       if match
         i = match[0].to_i
         index = i + 1 if i >= index
       end
     end
     
     # create the main config file 
     generate_template("templates/application.erb", "#{base_path}/#{name}", binding)
 
     # create a config with common setup
     generate_template("templates/common.erb", "#{base_path}/#{name}.common", binding)
 
     # create empty config file for custom configuration
     FileUtils.touch("#{base_path}/#{name}.custom")
 
     # link the folders
     File.symlink("#{base_path}/#{name}", "#{APACHE_PATH}/sites-enabled/#{sprintf("%03d",application_index)}-#{name}")
    end

    def create_mongrel_files
      base_path = "#{APACHE_PATH}/conf.d"
      start_port = (START_CLUSTER_PORT + (application_index*CLUSTER_PORT_OFFSET))
      ports = (start_port..(start_port+MONGREL_INSTANCES-1))
 
      generate_template("templates/mongrel_cluster.yml.erb", "/etc/mongrel_cluster/#{name}.yml", binding)
      generate_template("templates/proxy_cluster.conf.erb", "#{base_path}/#{name}.proxy_cluster.conf", binding)
      generate_template("templates/proxy_frontend.conf.erb", "#{base_path}/#{name}.proxy_frontend.conf", binding)
    end

    def delete_directory
      FileUtils.rm_rf application_path 
    end

    def delete_apache_files
      base_path = "#{APACHE_PATH}/sites-available"

      FileUtils.rm("#{base_batch}/{application_index}-{name}")
      FileUtils.rm("#{base_path}/#{name}")
      FileUtils.rm("#{base_path}/#{name}.common")
      FileUtils.rm("#{base_path}/#{name}.custom")
    end
 
    def delete_mongrel_files
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

        if match && match[2] == name
          return match[1]
          break
        end
      end
    end

  end
end
