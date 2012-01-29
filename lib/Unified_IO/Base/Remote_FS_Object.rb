
module Unified_IO
  module Base
    module Remote_FS_Object
      
      def initialize path, server = nil
        super(path)
        self.server = server if server
      end

      def exists_or_raise
        begin
          yield
        rescue Unified_IO::Remote::SSH::Exit_Error => e
          exists!
          raise e
        end
      end
      
    end # === module Remote_FS_Object
  end # === module Base
end # === module Unified_IO
