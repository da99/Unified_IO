

module Unified_IO
  
  module Remote
  class Server
    
    Invalid_Property = Class.new(RuntimeError)

    PROPS = [
      :ip, :port, :hostname, 
      :group,
      :user, :default, 
      :login, :root, :password
    ]
    
    module Class_Methods
      
      include Checked::DSL
      
      def config_file type, name
        symbol!( type ).in! [ :group, :server ]
        File_Path!( name )
        
        "configs/#{type}s/#{name}/config.rb"
      end
      
      def group? name
        dir = config_file( :group, name ).sub("config.rb", '')
        ::File.directory?( dir )
      end

      def server? name
        ::File.file?( config_file :server,  name)
      end
      
    end # === module Class_Methods
    
    extend Class_Methods

    attr_reader :origin, *PROPS
    attr_accessor :os_name

    def initialize file_or_hash, opts = {}
      
      hash = case file_or_hash
              
             when Hash
               file_or_hash
              
             when String
              
               if ::File.file?(file_or_hash)
                 eval(::File.read file_or_hash )
               else
                 base = eval(::File.read 'configs/base.rb' )
                 server = base.merge( eval(::File.read "configs/servers/#{file_or_hash}/config.rb") )
                 server[:hostname] = file_or_hash
                 if opts[:root]
                   server[:root] = true
                 end
                
                 server
               end
             else
               raise "Unknown data type: #{file_or_hash.inspect}"
             end

      invalid = hash.keys - PROPS
      raise Invalid_Property, "Invalid keys: #{invalid.inspect}" unless invalid.empty?

      if hash.has_key?(:password) && hash[:password].strip.empty?
        raise Invalid_Property, ":password can't be set as empty string."
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
        raise Invalid_Property, "Group must be set for server #{hostname}."
      end
      @group = group.to_s.strip
      
      if !hostname.is_a?(String)
        raise Invalid_Property, "Invalid hostname: #{hostname.inspect}"
      end
      
      @ip    ||= @hostname
      @user  ||= @login
      @login ||= @user

    end # === def initialize
    
  end # === class Server
  end # === module Remote
  
end # === module Unified_IO
