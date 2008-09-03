#!/usr/bin/ruby

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

#    This script creates a new application. It creates folders and 
#    configures apache, mongrel and mysql. 

require "rubygems"
require "optiflag"
require "fileutils"
require "#{File.dirname(__FILE__)}/../lib/app_helper"

module CommandLineArgs extend OptiFlagSet
  flag "application"
  flag "domain"
  optional_flag "env"
  and_process!
end

application = ARGV.flags.application
domain = ARGV.flags.domain
rails_env = ARGV.flags.env || 'production'

@app = Ec2onrails::AppHelper.new(application)

begin

 @app.create_directory
 @app.create_apache_files(domain)
 @app.create_mongrel_files(rails_env)
 @app.create_monitrc_file
 
end
