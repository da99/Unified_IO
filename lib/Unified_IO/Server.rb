

module Unified_IO
  
  class Server
    
    PROPS = [
      :ip, :port, :hostname, 
      :group,
      :user, :default, 
      :login, :root, :password
    ]
    
    attr_reader :origin, *PROPS
    attr_accessor :os_name

    def initialize file_or_hash
      
      hash = case file_or_hash
             when String
               eval(::File.read file_or_hash )
             when Hash
               file_or_hash
             else
               raise "Unknown data type: #{file_or_hash.inspect}"
             end

      invalid = hash.keys - PROPS
      raise "Invalid keys: #{invalid.inspect}" unless invalid.empty?

      if hash.has_key?(:password) && hash[:password].strip.empty?
        raise ":password can't be set as empty string."
      end
      
      if hash[:root]
        hash[:login] = 'root'
        hash.delete :root
      end
      
      if ENV['PASSWORD']
        hash[:password] = ENV['PASSWORD']
        hash[:login] = 'root'
      end

      @origin = hash
      origin.keys.each { |key|
        instance_variable_set :"@#{key}", origin[key]
      }
      
      @port ||= '22'
      if !group
        raise "Group must be set for server #{hostname}."
      end
      @group = group.to_s.strip
      
      if !hostname.is_a?(String)
        raise "Invalid hostname: #{hostname.inspect}"
      end
      
      @ip    ||= @hostname
      @user  ||= @login
      @login ||= @user

    end # === def initialize
    
  end # === class Server
  
end # === module Unified_IO
