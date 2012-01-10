require "Unified_IO/Base/File"

module Unified_IO

  module Remote

    class File

      module Base

        include ::Unified_IO::Base::File
        include ::Unified_IO::Remote::SSH::DSL

        def english_name
          "Remote file, #{address}"
        end

        def content
          exists!
          ssh.run "cat #{address}"
        end

        def exists?
          raw = ssh.exits(0,1).run( %~ [[ -f #{address} ]] && echo 'ok' ~ )
          raw.strip == 'ok'
        end

        def create raw
          super(raw) { |neo|
            t = Local::File.new(temp_address)
            t.create neo

            # From: http://stackoverflow.com/questions/5310063/ruby-netscp-and-custom-ports
            results = ssh.upload( temp_address, address )
            ::File.delete(temp_address)

            results
          }
        end

      end # === module Base

      include Base

    end # === class File

  end # === module Remote

end # === module Unified_IO



