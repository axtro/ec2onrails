# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{hennk-ec2onrails}
  s.version = "0.9.9.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["Paul Dowman, Adam Greene"]
  s.date = %q{2008-11-16}
  s.description = %q{Client-side libraries (Capistrano tasks) for managing and  deploying to EC2 on Rails servers.}
  s.email = %q{paul@pauldowman.com}
  s.extra_rdoc_files = ["CHANGELOG", "lib/ec2onrails/capistrano_utils.rb", "lib/ec2onrails/recipes.rb", "lib/ec2onrails/version.rb", "lib/ec2onrails.rb", "README.textile"]
  s.files = ["CHANGELOG", "COPYING", "lib/ec2onrails/capistrano_utils.rb", "lib/ec2onrails/recipes.rb", "lib/ec2onrails/version.rb", "lib/ec2onrails.rb", "Rakefile", "README.textile", "server/build-ec2onrails.sh", "server/files/etc/aliases", "server/files/etc/aliases.db", "server/files/etc/apache2/apache2.conf", "server/files/etc/apache2/conf.d/app.proxy_cluster.conf", "server/files/etc/apache2/conf.d/app.proxy_frontend.conf", "server/files/etc/apache2/mods-available/proxy.conf", "server/files/etc/apache2/sites-available/app.common", "server/files/etc/apache2/sites-available/app.custom", "server/files/etc/apache2/sites-available/default", "server/files/etc/apache2/sites-available/default-ssl", "server/files/etc/cron.d/backup_app_db_to_s3", "server/files/etc/cron.daily/app", "server/files/etc/cron.daily/logrotate_post", "server/files/etc/cron.hourly/app", "server/files/etc/cron.monthly/app", "server/files/etc/cron.weekly/app", "server/files/etc/denyhosts.conf", "server/files/etc/dpkg/dpkg.cfg", "server/files/etc/ec2onrails/balancer_members", "server/files/etc/ec2onrails/roles.yml", "server/files/etc/environment", "server/files/etc/event.d/monit", "server/files/etc/init.d/ec2-every-startup", "server/files/etc/init.d/ec2-first-startup", "server/files/etc/init.d/mongrel", "server/files/etc/init.d/set_roles", "server/files/etc/logrotate.d/apache2", "server/files/etc/logrotate.d/mysql-server", "server/files/etc/logrotate.d/rails", "server/files/etc/memcached.conf", "server/files/etc/mongrel_cluster/app.yml", "server/files/etc/monit/app.monitrc", "server/files/etc/monit/db_primary.monitrc", "server/files/etc/monit/memcache.monitrc", "server/files/etc/monit/monitrc", "server/files/etc/monit/system.monitrc", "server/files/etc/monit/web.monitrc", "server/files/etc/motd.tail", "server/files/etc/mysql/my.cnf", "server/files/etc/postfix/main.cf", "server/files/etc/rc0.d/K10mongrel", "server/files/etc/rc1.d/K10mongrel", "server/files/etc/rc2.d/S90mongrel", "server/files/etc/rc3.d/S90mongrel", "server/files/etc/rc4.d/S90mongrel", "server/files/etc/rc5.d/S90mongrel", "server/files/etc/rc6.d/K10mongrel", "server/files/etc/rcS.d/S91ec2-first-startup", "server/files/etc/rcS.d/S92ec2-every-startup", "server/files/etc/rcS.d/S99set_roles", "server/files/etc/ssh/sshd_config", "server/files/etc/sudoers", "server/files/etc/syslog.conf", "server/files/usr/local/ec2onrails/bin/archive_file.rb", "server/files/usr/local/ec2onrails/bin/backup_app_db.rb", "server/files/usr/local/ec2onrails/bin/backup_files.rb", "server/files/usr/local/ec2onrails/bin/mongrel_start", "server/files/usr/local/ec2onrails/bin/mongrel_stop", "server/files/usr/local/ec2onrails/bin/rails_env", "server/files/usr/local/ec2onrails/bin/rebundle.sh", "server/files/usr/local/ec2onrails/bin/restore_app_db.rb", "server/files/usr/local/ec2onrails/bin/restore_files.rb", "server/files/usr/local/ec2onrails/bin/set_rails_env", "server/files/usr/local/ec2onrails/bin/set_roles.rb", "server/files/usr/local/ec2onrails/config", "server/files/usr/local/ec2onrails/COPYING", "server/files/usr/local/ec2onrails/lib/mysql_helper.rb", "server/files/usr/local/ec2onrails/lib/s3_helper.rb", "server/files/usr/local/ec2onrails/lib/utils.rb", "server/files/usr/local/ec2onrails/startup-scripts/every-startup/get-hostname.sh", "server/files/usr/local/ec2onrails/startup-scripts/first-startup/create-dirs.sh", "server/files/usr/local/ec2onrails/startup-scripts/first-startup/generate-default-web-cert-and-key.sh", "server/files/usr/local/ec2onrails/startup-scripts/first-startup/misc.sh", "server/files/usr/local/ec2onrails/startup-scripts/first-startup/prepare-mysql-data-dir.sh", "server/files/usr/local/ec2onrails/startup-scripts/first-startup/setup_credentials.sh", "server/rakefile.rb", "setup.rb", "test/autobench.conf", "test/spec/lib/s3_helper_spec.rb", "test/spec/lib/s3_old.yml", "test/spec/test_files/test1", "test/spec/test_files/test2", "test/test_app/app/controllers/application.rb", "test/test_app/app/controllers/db_fast_controller.rb", "test/test_app/app/controllers/fast_controller.rb", "test/test_app/app/controllers/slow_controller.rb", "test/test_app/app/controllers/very_slow_controller.rb", "test/test_app/app/helpers/application_helper.rb", "test/test_app/app/helpers/db_fast_helper.rb", "test/test_app/app/helpers/fast_helper.rb", "test/test_app/app/helpers/slow_helper.rb", "test/test_app/app/helpers/very_slow_helper.rb", "test/test_app/Capfile", "test/test_app/config/boot.rb", "test/test_app/config/database.yml", "test/test_app/config/deploy.rb", "test/test_app/config/environment.rb", "test/test_app/config/environments/development.rb", "test/test_app/config/environments/production.rb", "test/test_app/config/environments/test.rb", "test/test_app/config/routes.rb", "test/test_app/db/schema.rb", "test/test_app/doc/README_FOR_APP", "test/test_app/public/404.html", "test/test_app/public/500.html", "test/test_app/public/dispatch.cgi", "test/test_app/public/dispatch.fcgi", "test/test_app/public/dispatch.rb", "test/test_app/public/favicon.ico", "test/test_app/public/images/rails.png", "test/test_app/public/javascripts/application.js", "test/test_app/public/javascripts/controls.js", "test/test_app/public/javascripts/dragdrop.js", "test/test_app/public/javascripts/effects.js", "test/test_app/public/javascripts/prototype.js", "test/test_app/public/robots.txt", "test/test_app/Rakefile", "test/test_app/README", "test/test_app/script/about", "test/test_app/script/breakpointer", "test/test_app/script/console", "test/test_app/script/destroy", "test/test_app/script/generate", "test/test_app/script/performance/benchmarker", "test/test_app/script/performance/profiler", "test/test_app/script/performance/request", "test/test_app/script/plugin", "test/test_app/script/process/inspector", "test/test_app/script/process/reaper", "test/test_app/script/process/spawner", "test/test_app/script/runner", "test/test_app/script/server", "test/test_app/test/functional/db_fast_controller_test.rb", "test/test_app/test/functional/fast_controller_test.rb", "test/test_app/test/functional/slow_controller_test.rb", "test/test_app/test/functional/very_slow_controller_test.rb", "test/test_app/test/test_helper.rb", "TODO", "Manifest", "ec2onrails.gemspec"]
  s.has_rdoc = true
  s.homepage = %q{http://ec2onrails.rubyforge.org}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Ec2onrails", "--main", "README.textile"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{ec2onrails}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Client-side libraries (Capistrano tasks) for managing and  deploying to EC2 on Rails servers.}
  s.test_files = ["test/test_app/test/functional/db_fast_controller_test.rb", "test/test_app/test/functional/fast_controller_test.rb", "test/test_app/test/functional/slow_controller_test.rb", "test/test_app/test/functional/very_slow_controller_test.rb", "test/test_app/test/test_helper.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<capistrano>, [">= 0", "= 2.4.3"])
      s.add_runtime_dependency(%q<archive-tar-minitar>, [">= 0", "= 0.5.1"])
      s.add_runtime_dependency(%q<optiflag>, [">= 0", "= 0.6.5"])
      s.add_development_dependency(%q<rake>, [">= 0.7.1"])
    else
      s.add_dependency(%q<capistrano>, [">= 0", "= 2.4.3"])
      s.add_dependency(%q<archive-tar-minitar>, [">= 0", "= 0.5.1"])
      s.add_dependency(%q<optiflag>, [">= 0", "= 0.6.5"])
      s.add_dependency(%q<rake>, [">= 0.7.1"])
    end
  else
    s.add_dependency(%q<capistrano>, [">= 0", "= 2.4.3"])
    s.add_dependency(%q<archive-tar-minitar>, [">= 0", "= 0.5.1"])
    s.add_dependency(%q<optiflag>, [">= 0", "= 0.6.5"])
    s.add_dependency(%q<rake>, [">= 0.7.1"])
  end
end
