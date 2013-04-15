require "Unified_IO/Base/File_System_Object"

module Unified_IO

  module Remote
    
    class Dir

      Not_Found = Class.new(RuntimeError)

      module Base

        include ::Unified_IO::Base::File_System_Object
        include ::Unified_IO::Base::Remote_FS_Object
        include ::Unified_IO::Remote::SSH::DSL

        def initialize path, server = nil
          super(path)
          server( server ) if server
        end

        def expand_path
          exists_or_raise { ssh_run("cd #{address} && pwd") }
        end

        def exists?
          ignore_exits("[[ -d #{address} ]] && echo ok", 1=>lambda { |e| e.result.empty? })
          .data == 'ok'
        end

        def files
          files = ssh("ls -Al #{address} | grep -v ^d").split("\n").map { |s| 
            File.join( address, s.split.last )
          }
        end

        def dirs
          dirs = ssh("ls -Al #{address} | grep ^d").split("\n").map { |s| 
            File.join( address, s.split.last )
          }
        end

      end # === module Base

      include Base

    end # === class Dir
    
  end # === module Remote
  
end # === module Unified_IO
