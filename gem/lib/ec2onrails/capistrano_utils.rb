module Ec2onrails
  module CapistranoUtils
    def run_local(command)
      result = system command
      raise("error: #{$?}") unless result
    end
    
    def run_init_script(script, arg)
      # since init scripts might have the execute bit unset by the set_roles script we need to check
      sudo "sh -c 'if [ -x /etc/init.d/#{script} ] ; then /etc/init.d/#{script} #{arg}; fi'"
    end
    
    def make_admin_role_for(role)
      newrole = "#{role.to_s}_admin".to_sym
      roles[role].each do |srv_def|
        options = srv_def.options.dup
        options[:user] = "admin"
        options[:port] = srv_def.port
        options[:no_release] = true
        role newrole, srv_def.host, options
      end
    end
    
    # return hostnames for the role named role_sym that has the specified options
    def hostnames_for_role(role_sym, options = {})
      role = roles[role_sym]
      unless role
        return []
      end
      role.select{|s| s.options == options}.collect{|s| s.host}
    end

    def start_mongrel(application)
      sudo "/usr/local/ec2onrails/bin/mongrel_start #{application}"
    end

    def stop_mongrel(application)
      sudo "/usr/local/ec2onrails/bin/mongrel_stop #{application}"
    end
  end
end
