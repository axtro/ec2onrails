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

exit unless File.stat("/etc/init.d/mysql").executable?
exit unless File.exists?("/mnt/app/current")

require "rubygems"
require "optiflag"
require "fileutils"
require "#{File.dirname(__FILE__)}/../lib/mysql_helper"
require "#{File.dirname(__FILE__)}/../lib/s3_helper"
require "#{File.dirname(__FILE__)}/../lib/utils"
require 'aws/s3'
include AWS::S3

module CommandLineArgs extend OptiFlagSet
  optional_flag "bucket"
  optional_flag "dir"
  optional_switch_flag "incremental"
  optional_switch_flag "reset"
  and_process!
end

# include the hostname in the bucket name so test instances don't accidentally clobber real backups
defaultDir = "database/current"
defaultTimestampedDir = "database/#{Time.new.strftime('%Y-%m-%d--%H-%M-%S')}"
dir = ARGV.flags.dir || defaultDir
@s3 = Ec2onrails::S3Helper.new(ARGV.flags.bucket, dir)
@mysql = Ec2onrails::MysqlHelper.new
@temp_dir = "/mnt/tmp/ec2onrails-backup-#{@s3.bucket}-#{dir.gsub(/\//, "-")}"
if File.exists?(@temp_dir)
  puts "Temp dir exists (#{@temp_dir}), aborting. Is another backup process running?"
  exit
end

begin
  FileUtils.mkdir_p @temp_dir
  if ARGV.flags.incremental
    # Incremental backup
    @mysql.execute_sql "flush logs"
    logs = Dir.glob("/mnt/log/mysql/mysql-bin.[0-9]*").sort
    logs_to_archive = logs[0..-2] # all logs except the last
    logs_to_archive.each {|log| @s3.store_file log}
    @mysql.execute_sql "purge master logs to '#{File.basename(logs[-1])}'"
  else
    # Full backup
    file = "#{@temp_dir}/dump.sql.gz"
    @mysql.dump(file, ARGV.flags.reset)
    if !ARGV.flags.bucket and ARGV.flags.reset and dir == defaultDir
      # Requested a binary log reset and no special target dir nor bucket specified. To maintain older database backups, rename the old dir on S3 to a timestamped name.
      begin
        Bucket.find(@s3.bucket, {:prefix => dir}).objects.map do |o|
          # The following sanity check is needed as Bucket.find sometimes returns objects without the defined prefix.
          if o.key.index(dir) == 0
            S3Object.rename(o.key, "#{defaultTimestampedDir}/#{File.basename(o.key)}", @s3.bucket)
          end
        end
      rescue
        # No current backup found.
      end
    end
    @s3.store_file file
  end
ensure
  FileUtils.rm_rf(@temp_dir)
end
