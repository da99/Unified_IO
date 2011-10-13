require 'Checked/Demand'
require "Unified_IO/Base/File_System_Object"

module Unified_IO

  module Local

    class Dir

      module Base

        include ::Unified_IO::Base::File_System_Object
        include Checked::Demand::DSL

        File_Not_Found = Class.new(RuntimeError)
        Too_Many_Files = Class.new(RuntimeError)

        public # ==============================

        def initialize addr
          super(::File.expand_path(addr))
          named_demand! 'Local file', self.address, :not_file!
        end

        def english_name
          "Local dir, #{address},"
        end

        def exists?
          ::Dir.exists?(address)
        end

        def files 
          visibles + hiddens
        end

        def visibles
          Local::File.filter Dir.glob(::File.join( address, '*' ))
        end

        def hiddens
          Local::File.filter Dir.glob(::File.join( address, '.*' ), ::File::FNM_DOTMATCH)
        end 

        def content? str
          begin
            content_address str
            true
          rescue File_Not_Found => e
            false
          end
        end

        def content_address str
          found = files.select { |file|
            file.content_same_as_as?( str )
          }

          err_msg = "with content: #{str[0..20]}..."

          case found.size
          when 0
            raise File_Not_Found, err_msg
          when 1
            found
          else
            raise Too_Many_Files, err_msg
          end
        end

        def content_in_any? content, *dirs
          found = dirs.flatten.detect { |raw_d|
            name = demand!(raw_d.to_s, :dir_address!)
            Local::Dir.new(::File.join address, name).content?(content)
          }

          !!found
        end


      end # === module Base

      include Base

    end # === class Dir
    
  end # === class Local
  
end # === module Unified_IO
