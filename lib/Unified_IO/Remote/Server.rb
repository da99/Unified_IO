

module Unified_IO
  module Remote
    class Server
      
      Not_Found  = Class.new(RuntimeError)
      Invalid_Property = Class.new(RuntimeError)
      Missing_Property = Class.new(RuntimeError)

      PROPS = [
        :ip, :port, :hostname, 
        :user, :default, 
        :login, :password,
        :custom
      ]

      module Base

        attr_reader :origin, *PROPS
        attr_accessor :os_name

        def initialize hash, opts = {}
          raise ArgumentError, "Argument not a hash: #{hash.inspect}" unless hash.is_a?(Hash)

          @custom = opts[:custom] || []
          valid_keys = custom + PROPS
          invalid = hash.keys - valid_keys
          raise Invalid_Property, "Invalid keys: #{invalid.inspect}" unless invalid.empty?

          if hash.has_key?(:password) && hash[:password].strip.empty?
            raise Invalid_Property, ":password can't be set as empty string."
          end

          custom.each { |key|
            raise Invalid_Property, "#{key.inspect}" unless key.is_a?(Symbol)
            raise Invalid_Property, "#{key.inspect} already defined" if respond_to?(key)
            raise Missing_Property, "#{key.inspect}" unless hash.has_key?(key)
          }

          if ENV['PASSWORD']
            hash[:password] = ENV['PASSWORD']
            hash[:login] = 'root'
          end

          @origin = hash

          origin.keys.each { |key|
            instance_variable_set :"@#{key}", origin[key] if valid_keys.include?(key)

            if custom.include?(key)
              eval %~
              def self.#{key}
                @#{key}
              end
            ~, nil, __FILE__, __LINE__ - 3 
            end
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

      end # === module Base
      
      include Base

    end # === class Server
  end # === module Remote
end # === module Unified_IO
