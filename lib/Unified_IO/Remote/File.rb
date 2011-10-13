require "Unified_IO/Base/File"

module Unified_IO

  module Remote

    class File

      module Base

        include ::Unified_IO::Base::File

        def english_name
          "Remote file, #{address},"
        end

        def content
          exists!
          ssh.<<( :cat, address )
        end

        def exists?
          raw = ssh( %~ [[ -f #{address} ]] && echo 'ok' ~, :exits => [0,1] )
          raw.strip == 'ok'
        end

        def create raw
          super() {
            t = Local::File.new(temp_address)
            t.create raw

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


__END__


def cache
  @cache ||= begin
               reset
               @cache
             end
end

def reset
  @cache = Args.new(:content)
end
