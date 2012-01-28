require "Unified_IO/Base/File_System_Object"

module Unified_IO

  module Remote
    
    class Dir

      Not_Found = Class.new(RuntimeError)

      module Base

        include ::Unified_IO::Base::File_System_Object
        include ::Unified_IO::Remote::SSH::DSL

        def exists?
          ignore_exits("[[ -d #{address} ]] && echo ok", 1=>lambda { |e| e.result.empty? })
          .data == ['ok']
        end

      end # === module Base

      include Base

    end # === class Dir
    
  end # === module Remote
  
end # === module Unified_IO
