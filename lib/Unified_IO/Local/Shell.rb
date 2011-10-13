require 'term/ansicolor'

module Unified_IO

  class Shell
    
    module DSL
      
      def shell raw_cmd = :none
        case cmd 
        when :none
          Shell.new
        else
          Shell.new.run raw_cmd
        end

      end

    end # === module DSL
    
    module Base
      
      include Term::ANSIColor
      
      def run raw
        cmd = cleaner(raw_cmd, :shell)
        shell.tell cmd
        output = %x! #{cmd} !
        raise( shell.yell("Local Error: #{output}") ) if $?.exitstatus != 0
        shell.display output

        output
      end
      
      # 
      # Used for showing results.
      #
      def display msg
        puts msg
      end

      # 
      # Used for warning messages.
      #
      def notify msg
        colored_puts :yellow, *msgs
      end

      # 
      # Tell user what you are doing.
      #
      def tell *msgs
        colored_puts :blue, *msgs
      end

      # 
      # Show off errors.
      #
      def yell *msgs
        colored_puts :red, *msgs
      end
      
      def colored_puts color, *msgs
        msgs.flatten.each { |str|
          puts send( color, str.to_s )
        }
      end

    end # === module Base
    
    include Base
    
  end # === class Shell
  
end # === module Unified_IO
