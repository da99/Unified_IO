
module Unified_IO
  module Remote
    class Server_Group
      
      Not_Found = Class.new(RuntimeError)

      module Class_Methods
        
        def all
          all = ::Dir.glob(Remote::Server.config_file :groups, '*' ).map { |file|
            name = begin
                     pieces = file.split('/')
                     pieces.pop unless ::File.directory?(file)
                     pieces.pop.to_s
                   end

            group = Unified_IO::Remote::Server_Group.new( name )

            if group.name == name
              group
            else
              nil
            end

          }.compact
          
          raise Not_Found, "None." if all.empty?
          all
        end

      end # === module Class_Methods
      
      extend Class_Methods
      
      module Base
        
        attr_reader :servers, :name

        def initialize raw_name
          @name = raw_name
          @servers = ::Dir.glob(Remote::Server.config_file :servers, '*' ).map { |file|

            hostname = begin
                         pieces = file.split('/')
                         pieces.pop
                         pieces.pop
                       end
            
            server = Unified_IO::Remote::Server.new( hostname )
          
            if server.group.to_s == name.to_s
              server
            else
              nil
            end
              
          }.compact

          raise Server_Group::Not_Found, name if servers.empty?
        end

      end # === module Base
      
      include Base

    end # === class Server
  end # === module Remote
end # === module Unified_IO
