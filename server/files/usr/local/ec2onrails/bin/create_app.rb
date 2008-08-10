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
require "#{File.dirname(__FILE__)}/../lib/mysql_helper"
require "#{File.dirname(__FILE__)}/../lib/utils"

module CommandLineArgs extend OptiFlagSet
  optional_flag "application"
  optional_flag "servername"
  optional_flag "db_name"
  optional_flag "db_user"
  optional_flag "db_password"
  and_process!
end

application = ARGV.flags.application
servername = ARGV.flags.servername
db_name = ARGV.flags.db_name
db_user = ARGV.flags.db_user
db_password = ARGV.flags.db_password

@mysql = Ec2onrails::MysqlHelper.from_settings(db_name, db_user, db_password)
@app = Ec2onrails::AppHelper.new(application)

begin

 @app.create_directory
 @app.create_apache_files
 @app.create_mongrel_files
 @mysql.create_database
 
end
