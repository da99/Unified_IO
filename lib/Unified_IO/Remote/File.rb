require "Unified_IO/Base/File"

module Unified_IO

  module Remote

    class File
      
      Invalid_Address = Class.new(RuntimeError)
      Overwrite_Error = Class.new(RuntimeError)
      Not_Found       = Class.new(RuntimeError)
      Not_A_File      = Class.new(RuntimeError)

      module Base

        include ::Unified_IO::Base::File
        include ::Unified_IO::Base::Remote_FS_Object
        include ::Unified_IO::Remote::SSH::DSL

        def content
          exists!
          ssh_run "cat #{address}"
        end
      
        def expand_path
          ::File.join(ssh_run('pwd'), address)
        end

        def exists?
          r = ignore_exits(%~ [[ -f #{address} ]] && echo 'ok' ~, 1=> lambda { |e| e.result.empty? }) 
          r.data == 'ok'
        end

        def create raw
          super(raw) { |neo|
            t = Local::File.new(temp_address)
            t.create neo

            # From: http://stackoverflow.com/questions/5310063/ruby-netscp-and-custom-ports
            results = scp_upload( temp_address, address )
            ::File.delete(temp_address)

            results
          }
        end

      end # === module Base

      include Base

    end # === class File

  end # === module Remote

end # === module Unified_IO



