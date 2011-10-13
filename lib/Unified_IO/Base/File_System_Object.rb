require "Checked/Demand"

module Unified_IO
  module Base
    module File_System_Object

      include Checked::Demand::DSL

      attr_reader :address

      def initialize addr
        @address = begin
                     a = demand!(addr, :string!, :not_empty!)
                     a
                   end
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

    end # === module File_System_Object
  end # === module Base
end # === module Unified_IO
