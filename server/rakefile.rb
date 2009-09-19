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


# This script is meant to be run by build-ec2onrails.sh, which is run by
# Eric Hammond's Ubuntu build script: http://alestic.com/
# e.g.:
# bash /mnt/ec2ubuntu-build-ami --script /mnt/ec2onrails/server/build-ec2onrails.sh ...



require "rake/clean"
require 'yaml'
require 'erb'
require "#{File.dirname(__FILE__)}/../lib/ec2onrails/version"

if `whoami`.strip != 'root'
  raise "Sorry, this buildfile must be run as root."
end

@packages = %w(
  adduser
  apache2
  aptitude
  bison
  ca-certificates
  cron
  curl
  flex
  gcc
  git-core
  irb
  less
  libdbm-ruby
  libgdbm-ruby
  libmysql-ruby
  libopenssl-ruby
  libreadline-ruby
  libruby
  libssl-dev
  libyaml-ruby
  libzlib-ruby
  logrotate
  make
  mailx
  memcached
  mysql-client
  mysql-server
  nano
  openssh-server
  postfix
  rdoc
  ri
  rsync
  ruby
  ruby1.8-dev
  subversion
  unzip
  vim
  wget
  xfsprogs
)

# HACK: some packages just fail with apt-get but work fine
#       with aptitude.  These generally are virtual packages
@aptitude_packages = %w(
  libmysqlclient-dev
)

# NOTE: the amazon-ec2 gem is now at github, maintained by
#       grempe-amazon-ec2.  Will move back to regular amazon-ec2
#       gem if/when he cuts a new release with volume and snapshot
#       support included
@rubygems = [
  "grempe-amazon-ec2",
  "aws-s3",
  "memcache-client",
  "mongrel",
  "mongrel_cluster",
  "optiflag",
  "rails -v 2.2.2",
  "rails -v 2.0.2",
  "rake",
  "archive-tar-minitar"
]

@build_root = "/mnt/build"
@fs_dir = "#{@build_root}/ubuntu"

@version = [Ec2onrails::VERSION::MAJOR, Ec2onrails::VERSION::MINOR, Ec2onrails::VERSION::TINY].join('.')

task :default => :configure

desc "Removes all build files"
task :clean_all do |t|
  rm_rf @build_root
end

desc "Use apt-get to install required packages inside the image's filesystem"
task :install_packages do |t|
  unless_completed(t) do
    ENV['DEBIAN_FRONTEND'] = 'noninteractive'
    ENV['LANG'] = ''
    run_chroot "apt-get install -y #{@packages.join(' ')}"
    run_chroot "apt-get clean"
    
    #lets run the aptitude-only packages
    run_chroot "aptitude install -y #{@aptitude_packages.join(' ')}"
    run_chroot "aptitude clean"
  end
end

desc "Install required ruby gems inside the image's filesystem"
task :install_gems => [:install_packages] do |t|
  unless_completed(t) do
    run_chroot "sh -c 'cd /tmp && wget -q http://rubyforge.org/frs/download.php/60718/rubygems-1.3.5.tgz && tar zxf rubygems-1.3.5.tgz'"
    run_chroot "sh -c 'cd /tmp/rubygems-1.3.5 && ruby setup.rb'"
    run_chroot "ln -sf /usr/bin/gem1.8 /usr/bin/gem"
    run_chroot "gem update --system --no-rdoc --no-ri"
    run_chroot "gem update --no-rdoc --no-ri"
    run_chroot "gem sources -a http://gems.github.com"
    @rubygems.each do |gem|
      run_chroot "gem install #{gem} --no-rdoc --no-ri"
    end
  end
end

desc "Compile and install monit"
task :install_monit => [:install_packages] do |t|
  unless_completed(t) do
    run_chroot "sh -c 'cd /tmp && wget -q http://www.tildeslash.com/monit/dist/monit-4.10.1.tar.gz'"
    run_chroot "sh -c 'cd /tmp && tar xzvf monit-4.10.1.tar.gz'"
    run_chroot "sh -c 'cd /tmp/monit-4.10.1 && ./configure  --sysconfdir=/etc/monit/ --localstatedir=/var/run && make && make install'"
  end
end

desc "Configure the image"
task :configure => [:install_gems, :install_monit] do |t|
  unless_completed(t) do
    sh("cp -r files/* #{@fs_dir}")
    sh("find #{@fs_dir} -type d -name .svn | xargs rm -rf")

    replace("#{@fs_dir}/etc/motd.tail", /!!VERSION!!/, "Version #{@version}")
    
    run_chroot "a2enmod deflate"
    run_chroot "a2enmod proxy_balancer"
    run_chroot "a2enmod proxy_http"
    run_chroot "a2enmod rewrite"
    
    run_chroot "/usr/sbin/adduser --gecos ',,,' --disabled-password app"
    run_chroot "/usr/sbin/adduser --gecos ',,,' --disabled-password admin"
    run_chroot "/usr/sbin/adduser admin adm"
    run_chroot "/usr/sbin/addgroup sudoers"
    
    run "echo '. /usr/local/ec2onrails/config' >> #{@fs_dir}/root/.bashrc"
    run "echo '. /usr/local/ec2onrails/config' >> #{@fs_dir}/home/app/.bashrc"
    run "echo '. /usr/local/ec2onrails/config' >> #{@fs_dir}/home/admin/.bashrc"
    
    %w(apache2 mysql auth.log daemon.log kern.log mail.err mail.info mail.log mail.warn syslog user.log).each do |f|
      rm_rf "#{@fs_dir}/var/log/#{f}"
      run_chroot "ln -sf /mnt/log/#{f} /var/log/#{f}"
    end
    
    run "touch #{@fs_dir}/ec2onrails-first-boot"
    
    # TODO find out the most correct solution here, there seems to be a bug in
    # both feisty and gutsy where the dhcp daemon runs as dhcp but the dir
    # that it tries to write to is owned by root and not writable by others.
    run_chroot "chown -R dhcp /var/lib/dhcp3"
  end
end

desc "This task is for deploying the contents of /files to a running server image to test config file changes without rebuilding."
task :deploy_files do |t|
  raise "need 'key' and 'host' env vars defined" unless ENV['key'] && ENV['host']
  run "rsync -rlvzcC --rsh='ssh -l root -i #{ENV['key']}' files/ #{ENV['host']}:/"
end

##################

# Execute a given block and touch a stampfile. The block won't be run if the stampfile exists.
def unless_completed(task, &proc)
  stampfile = "#{@build_root}/#{task.name}.completed"
  unless File.exists?(stampfile)
    yield  
    touch stampfile
  end
end

def run_chroot(command, ignore_error = false)
  run "chroot '#{@fs_dir}' #{command}", ignore_error
end

def run(command, ignore_error = false)
  puts "*** #{command}" 
  result = system command
  raise("error: #{$?}") unless result || ignore_error
end

# def mount(type, mount_point)
#   unless mounted?(mount_point)
#     puts
#     puts "********** Mounting #{type} on #{mount_point}..."
#     puts
#     run "mount -t #{type} none #{mount_point}"
#   end
# end
# 
# def mounted?(mount_point)
#   mount_point_regex = mount_point.gsub(/\//, "\\/")
#   `mount`.select {|line| line.match(/#{mount_point_regex}/) }.any?
# end

def replace_line(file, newline, linenum)
  contents = File.open(file, 'r').readlines
  contents[linenum - 1] = newline
  File.open(file, 'w') do |f|
    contents.each {|line| f << line}
  end
end

def replace(file, pattern, text)
  contents = File.open(file, 'r').readlines
  contents.each do |line|
    line.gsub!(pattern, text)
  end
  File.open(file, 'w') do |f|
    contents.each {|line| f << line}
  end
end
