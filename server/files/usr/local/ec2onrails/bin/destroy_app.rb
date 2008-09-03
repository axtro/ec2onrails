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

#    This script destroys an application. It removed folders and 
#    removes configurion apache, mongrel. 

require "rubygems"
require "optiflag"
require "fileutils"
require "#{File.dirname(__FILE__)}/../lib/app_helper"

module CommandLineArgs extend OptiFlagSet
  flag "application"
  and_process!
end

application = ARGV.flags.application

@app = Ec2onrails::AppHelper.new(application)

begin

 @app.destroy_directory
 @app.destroy_apache_files
 @app.destroy_mongrel_files
 @app.destroy_monitrc_file
 
end
