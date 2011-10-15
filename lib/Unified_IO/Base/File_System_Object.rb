require "Checked/Demand"

module Unified_IO
  module Base
    module File_System_Object

      include Checked::Demand::DSL

      private
      attr_writer :address
      
      public
      attr_reader :address

      def initialize addr
        self.address = begin
                     a = demand!(addr, :file_address!)
                     a
                   end
        (self.address = expand_path) if local?
      end

      def english_name
        @english_name ||= begin
                            name = self.class.name.downcase
                            .split('::')
                            .last
                            .capitalize
                            .gsub('_', ' ') 
                          "#{name}, #{address.inspect},"
                          end
      end

      def not_exists!
        demand! self, :not_exists!
        true
      end

      def exists!
        demand! self, :exists!
        true
      end


      def expand_path
        if local?
          File.expand_path address
        else
          File.join(ssh.pwd, address)
        end
      end

    end # === module File_System_Object
  end # === module Base
end # === module Unified_IO
