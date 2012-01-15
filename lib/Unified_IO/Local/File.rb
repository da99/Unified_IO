require 'Checked'
require "Unified_IO/Base/File"

module Unified_IO

  module Local

    class File
      
      module Class_Methods

        include Checked::DSL::Racked

        def filter *arr
          arr
          .flatten
          .map { |path| ::File.file?(path) ? Local::File.new(path) : nil }
          .compact
        end

        def read raw_addr
          addr = File_Path!(raw_addr)
          String!(::File.read addr ).file_read!
        end

      end # === module Dsl

      module Base

        include Checked::DSL
        include ::Unified_IO::Base::File
        include ::Unified_IO::Local::Shell::DSL

        def initialize addr
          super(::File.expand_path(addr))
          File_Path!( "Local file", address ).not_dir!
        end

        def english_name
          "Local file, #{address}"
        end

        def content
          exists!
          Local::File.read address
        end

        def exists?
          ::File.file?(address)
        end

        def create raw
          super(raw) {
            ::File.open(address, 'w') { |io| 
              io.write String!(raw).file_content!
            }
          }
        end

      end # === module Base

      include Base

      class << self
        include Class_Methods
      end

    end # === class File
    
  end # === module Local
  
end # === module Unified_IO
