require "Unified_IO/Base/File_System_Object"
require "Checked/Demand"

module Unified_IO

  module Base

    module File

      include Base::File_System_Object
      include Checked::Demand::DSL

      def temp_address
        @temp_address ||= "/tmp/#{address.gsub('/',',')}.#{Time.now.strftime('%F.%H.%M.%S')}"
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
      
      def untar 
        cmd = case address
              when /\.tar$/
                "tar -xvf #{address}"
              when /\.tar.gz/
                "tar -zxvf #{address}"
              when /\.zip$/
                "unzip #{address}"
              else
                raise "Unknown address type: #{address}"
              end
        
        run cmd
      end
      
      # For modes, see http://www.ruby-doc.org/core/classes/IO.html
      def write_to_file pos = :top, raw_file, &blok
        backup_file raw_file

        file = File.expand_path(raw_file)
        mode = case pos
               when :top
               when :bottom
               else
                 raise "Position can only be :top or :bottom: #{pos.inspect}"
               end

        contents = File.read(file)

        File.open( file , "w") { |io|
          io.write( "#{contents}\n" )if pos == :bottom
          blok.call(contents, io)
          io.write( "#{contents}" ) if pos == :top
        }
      end
      
    end # === module File
    
  end # === module Base

end # === module Unified_IO

