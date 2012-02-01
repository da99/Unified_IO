

module Unified_IO
  module Remote
    class Server
      
      Not_Found  = Class.new(RuntimeError)
      Invalid_Property = Class.new(RuntimeError)

      PROPS = [
        :ip, :port, :hostname, 
        :user, :default, 
        :login, :root, :password
      ]

      attr_reader :origin, *PROPS
      attr_accessor :os_name

      def initialize hash, opts = {}
        raise ArgumentErro, "Argument not a hash: #{hash.inspect}" unless hash.is_a?(Hash)

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
        @port = Integer(@port)

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
