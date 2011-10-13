require "Unified_IO/Base/File_System_Object"
require "Checked/Demand"

module Unified_IO

  module Base

    module File

      include Base::File_System_Object
      include Checked::Demand::DSL

      def temp_address
        @temp_address ||= "tmp/#{address.gsub('/',',')}.#{Time.now.to_s}"
      end

      def content_same_as? raw
        content == demand!(raw, :file_content!)
      end

      def create neo

        if exists? && content_same_as?(neo)
          shell.notify "File already written: #{address}"
          return false
        end

        not_exists!
        yield demand!(neo, :file_content!)
      end

    end # === module File
    
  end # === module Base

end # === module Unified_IO

