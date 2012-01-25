require "Unified_IO/Base/File_System_Object"

module Unified_IO

  module Remote
    
    class Dir

      Not_Found = Class.new(RuntimeError)

      module Base

        include ::Unified_IO::Base::File_System_Object
        include ::Unified_IO::Remote::SSH::DSL

        def exists?
          found = false
          ssh_connection.exec!("cd #{dir}") { |channel, stream, data|
            if stream == :stdout
              found = true
            end 
          }

          found
        end

      end # === module Base

      include Base

    end # === class Dir
    
  end # === module Remote
  
end # === module Unified_IO
