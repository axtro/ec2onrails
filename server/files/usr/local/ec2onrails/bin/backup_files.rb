#!/usr/bin/ruby

# Tars a given file or directory and uploads it to S3 using a time-stamped name.
# Takes 2 required and 1 optional flags:
#   -sourceFileOrDir  The full path to the file or dir to be saved to S3
#   -dir              The directory inside the bucket to save above file/dir to
#   -bucket           [optional] The bucket where <dir> will be created. If this is not specified, it defaults to the bucket_base_name from s3.yml concatenated with the hostname.

exit unless File.exists?("/mnt/app/current")

require "rubygems"
require 'zlib'
require 'archive/tar/minitar'
include Archive::Tar
require "optiflag"
require "fileutils"
require "#{File.dirname(__FILE__)}/../lib/s3_helper"
require "#{File.dirname(__FILE__)}/../lib/utils"

module CommandLineArgs extend OptiFlagSet
  flag "sourceFileOrDir"
  flag "dir"
  optional_flag "bucket"

  and_process!
end

# include the hostname in the bucket name so test instances don't accidentally clobber real backups
bucket = ARGV.flags.bucket
dir = ARGV.flags.dir
@s3 = Ec2onrails::S3Helper.new(bucket, dir)
@temp_dir = "/mnt/tmp/backup-files-#{@s3.bucket}-#{dir.gsub(/\//, "-")}"
local_file = File.join(@temp_dir, "#{Time.new.strftime('%Y-%m-%d--%H-%M-%S')}.tar")
if File.exists?(@temp_dir)
  puts "Temp dir exists (#{@temp_dir}), aborting. Is another backup process running?"
  exit
end

begin
  FileUtils.mkdir_p @temp_dir
  
  source_file = ARGV.flags.sourceFileOrDir
  
  FileUtils.cd(File.dirname(source_file)) do
    File.open(local_file, 'wb') { |tar| Minitar.pack(File.basename(source_file), tar) }
  end
  
  @s3.store_file(local_file)
ensure
  FileUtils.rm_rf(@temp_dir)
end
