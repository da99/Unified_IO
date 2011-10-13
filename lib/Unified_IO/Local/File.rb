require 'Checked/Demand'
require "Unified_IO/Base/File"

module Unified_IO

  module Local

    class File
      
      module Class_Methods

        include Checked::Demand::DSL

        def filter *arr
          arr.flatten
          .select { |path| ::File.file?(path) }
          .map { |path|  Local::File.new(path) }
        end

        def read raw_addr
          addr = demand!(raw_addr, :file_address!)
          demand!(::File.read(addr), :file_read!)
        end

      end # === module Dsl

      module Base

        include ::Unified_IO::Base::File
        include Checked::Demand::DSL

        def initialize addr
          super(::File.expand_path(addr))
          named_demand! "Local file", address, :not_dir!
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
            io.write demand!(raw, :file_content!)
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
