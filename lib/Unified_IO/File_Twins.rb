
module Unified_IO

  # 
  # Used to download files to the Desktop for
  # examination.  All other file downloads
  # should use Template_File
  #
  class File_Twins

    module Base
      
      include ::Unified_IO::Local::Shell::DSL
      include ::Unified_IO::Remote::SSH::DSL
      attr_reader :local, :remote

      def initialize local_addr, remote_addr
        @local   = Local::File.new(local_addr)
        @remote  = Remote::File.new(remote_addr)
      end

      def server= s
        remote.server= s
        super
      end

      def uploaded?
        return false if not remote.exists?
        local.exists!
        local.content_same_as? remote.content
      end
      
      def downloaded?
        return false if not local.exists?
        remote.exists!
        local.content_same_as? remote.content
      end

      def upload 
        if uploaded?
          shell.notify(
            "File already uploaded [from] [to]:", local.address, remote.address
          )
          return false
        end
        
        shell.tell(
          "Uploading [from] [to]:", local.address, remote.address
        )

        remote.create local.content
      end # === def upload      
      
      def download
        raise "Implementation not done."
        if downloaded?
          shell.notify(
            "File downloaded [from] [to]:", remote.address, local.address
          )
          return false
        end
        
        shell.tell(
          "Downloading [from] [to]:", remote.address, local.address
        )

        local.create remote.content
      end
    end # === module Base
    
    include Base
    
  end # === class Desktop_File
  
end # === module Unified_IO
