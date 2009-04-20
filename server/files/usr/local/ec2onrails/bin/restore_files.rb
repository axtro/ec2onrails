#!/usr/bin/ruby

# Downloads and untars a backup created with backup_files.rb from a given directory from S3.
# Takes 2 required and 2 optional flags:
#   -destDir          The full path to the dir where the downloaded file should be extracted
#   -dir              The directory inside the bucket where the timestamped backups can be found
#   -timestamp        [optional] Download the given timestamp. If this flag is not given, the most recent timestamp will be downloaded. Timestamps have to be in the following format: YYYY-MM-DD--HH-MM-SS
#   -bucket           [optional] The bucket where <dir> will be created. If this is not specified, it defaults to the bucket_base_name from s3.yml concatenated with the hostname.

require "rubygems"
require 'zlib'
require 'archive/tar/minitar'
include Archive::Tar
require "optiflag"
require "fileutils"
require "#{File.dirname(__FILE__)}/../lib/s3_helper"
require "#{File.dirname(__FILE__)}/../lib/utils"
require 'aws/s3'
include AWS::S3

module CommandLineArgs extend OptiFlagSet
  flag "destDir"
  flag "dir"
  optional_flag "timestamp"
  optional_flag "bucket"
  
  and_process!
end

dir = ARGV.flags.dir
@s3 = Ec2onrails::S3Helper.new(ARGV.flags.bucket, dir)
@temp_dir = "/mnt/tmp/backup-files-#{@s3.bucket}-#{dir.gsub(/\//, "-")}"
if File.exists?(@temp_dir)
  puts "Temp dir exists (#{@temp_dir}), aborting. Is another backup process running?"
  exit
end

begin
  FileUtils.mkdir_p @temp_dir
  
  if ARGV.flags.timestamp
    timestamp = ARGV.flags.timestamp
  else
    # The user didn't supply a timestamp to load, so get a list of all objects inside <bucket>/<dir> and take the youngest timestamp.
    # <bucket>/<dir> has the following structure:
    #   <timestamp/>
    #     part_00
    #     part_01
    #     ....
    # so we have to extract the timestamp substring from the last object when sorted alphabetically.
    bucket = Bucket.find(@s3.bucket, {:prefix => dir})
    names_to_buckets = bucket.objects.map { |o| {:key => o.key, :object => o }}
    names_to_buckets.sort_by {|a| a[:key]}
    timestamp = File.basename(File.dirname(names_to_buckets.last[:key]))
  end
  
  puts "Retrieving data from #{timestamp}..."
  @s3.dir = dir + "/" + timestamp
  @s3.retrieve_files("part_", @temp_dir)

  puts "Extracting files..."
  FileUtils.cd(ARGV.flags.destDir) do
    tar_parts = Dir.glob(File.join(@temp_dir, "part_??")).sort
    Ec2onrails::Utils.run "cat #{tar_parts.join(" ")} | tar -x"
  end
ensure
  FileUtils.rm_rf(@temp_dir)
end
