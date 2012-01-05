
module Unified_IO
  module Remote
    class Server_Group
      module Class_Methods
        
        def group? name
          ::File.file?(Server.config_file :group, name)
        end
        
      end # === module Class_Methods
      
      include Class_Methods
      
      module Base
        
        attr_reader :servers, :name

        def initialize raw_name
          @name = ['*', :all, 'all'].include?(raw_name) ? '*' : raw_name
          @servers = ::Dir.glob('configs/servers/*/config.rb').map { |file|

            hostname = begin
                         pieces = file.split('/')
                         pieces.pop
                         pieces.pop
                       end
            
            server = Unified_IO::Remote::Server.new( hostname )
          
            if all? || ( server.group.to_s == name.to_s )
              server
            else
              nil
            end
              
          }.compact

        end
        
        def all?
          @name == '*'
        end

      end # === module Base
      
      include Base

    end # === class Server
  end # === module Remote
end # === module Unified_IO
