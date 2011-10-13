
module Unified_IO

  # 
  # Used to download files to the Desktop for
  # examination.  All other file downloads
  # should use Template_File
  #
  class File_Twins

    module Base
      
      attr_reader :local, :far

      def initialize local_addr, far_addr
        @local   = Local::File.new(local_addr)
        @far     = Far::File.new(far_addr)
      end

      def uploaded?
        return false if not far.exists?
        local.exists!
        local.content_same_as? far.content
      end
      
      def downloaded?
        return false if not local.exists?
        far.exists!
        local.content_same_as? far.content
      end

      def upload 
        if uploaded?
          notify(
            "File already uploaded [from] [to]:", local.address, far.address
          )
          return false
        end
        
        tell(
          "Uploading [from] [to]:", local.address, far.address
        )

        far.create local.content
      end # === def upload      
      
      def download
        if downloaded?
          shell.notify(
            "File downloaded [from] [to]:", far.address, local.address
          )
          return false
        end
        
        shell.tell(
          "Downloading [from] [to]:", far.address, local.address
        )

        local.create far.content
      end
    end # === module Base
    
    include Base
    
  end # === class Desktop_File
  
end # === module Unified_IO
