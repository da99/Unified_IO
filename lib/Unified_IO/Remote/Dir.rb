require "Unified_IO/Base/File_System_Object"

module Unified_IO

  class Far_Dir

    module Base
      
      include ::Unified_IO::Base::File_System_Object
      
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
    
  end # === class Far_Dir
  
end # === module Unified_IO
