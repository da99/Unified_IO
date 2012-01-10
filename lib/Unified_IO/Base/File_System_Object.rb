require "Checked"

module Unified_IO
  module Base
    module File_System_Object

      include Checked::DSL

      private
      attr_writer :address
      
      public
      attr_reader :address

      def initialize addr
        self.address = File_Path!(addr)
        (self.address = expand_path) if local?
      end

      def english_name
        @english_name ||= begin
                            name = self.class.name.downcase
                            .split('::')
                            .last
                            .capitalize
                            .gsub('_', ' ') 
                          "#{name}, #{address.inspect}"
                          end
      end

      def not_exists!
        demand!( self ).not_be! :exists?
        true
      end

      def exists!
        demand!( self ).be! :exists?
        true
      end


      def expand_path
        if local?
          ::File.expand_path address
        else
          ::File.join(ssh.pwd, address)
        end
      end
      
      def remote?
        !local?
      end
      
      def local?
        @is_local ||= begin
                        klass_name = self.class.name.to_s
                        if klass_name['::Local::']
                          true
                        elsif klass_name['::Remote::']
                          false
                        else
                          raise "Could not figure out location type: #{klass_name}"
                        end
                      end
      end

    end # === module File_System_Object
  end # === module Base
end # === module Unified_IO
