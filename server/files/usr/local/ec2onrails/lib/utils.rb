module Ec2onrails
  module Utils
    def self.run(command)
      result = system command
      raise("error: #{$?}") unless result
    end
  
    def self.rails_env(application)
      `/usr/local/ec2onrails/bin/rails_env --application #{application}`.strip
    end
    
    def self.hostname
      `hostname -s`.strip
    end

    def self.generate_template(template_path, destination_path, template_binding)
      template = ERB.new(IO.read(template_path))

      File.open(destination_path, "w") do |f| 
        f.write(template.result(template_binding))}
      end
    end
  end
end
