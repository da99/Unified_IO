require 'term/ansicolor'
require 'Checked/Clean'

module Unified_IO
  module Local
    class Shell

      Failed = Class.new(RuntimeError)

      module DSL

        def shell
          Shell.new
        end

        def shell!
          Shell
        end

      end # === module DSL
      
      module Class_Methods
        
        def run *args
          new.run *args
        end
				
				def quiet?
					return false unless defined?(@quiet)
					@quiet
				end

				def quiet
					@quiet = true
				end

				def loud
					@quiet = false
				end
        
      end # === module Class_Methods

      module Base

        include ::Unified_IO::Base::Shell
        include Term::ANSIColor
        include Checked::Clean::DSL
        include Checked::Demand::DSL

        attr_reader :address
        def initialize raw_addr = '.'
          addr = demand!(raw_addr, :file_address!)
          @address = ::File.expand_path(addr)
        end

        def run raw, &blok

          @bash_ver_num ||= begin
                              @bash_version = %x! bash --version ![%r!GNU bash, version (\d)!]
                              $1.to_i
                            end

          single_line = clean(raw, :shell)
          cmd = "cd #{address} && #{single_line}  "
          tell cmd
          bash = if @bash_ver_num == 3
              %! sudo -u $USER -i %s 2>&1 ! % cmd.gsub('"', "'").gsub('&', "\\&")
                 elsif @bash_ver_num >= 4
              %! sudo -u $USER -i sh -c %s 2>&1 ! % cmd.inspect
                 else
                   raise "Unknown Bash version: #{@bash_version}"
                 end

          results = IO.popen( bash, (blok ? 'r+' : 'r')  ) do |io|
            blok && blok.call(io)
            io.read
          end

          stat = $?.exitstatus

          if stat != 0
            raise Failed, "EXIT: #{stat.inspect} OUTPUT: \n !!!-- #{results} ---!!!"
          end

          results.strip
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
        # Completely same as :notify.
        #
				def warn msg
					notify msg
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
				
				def response *msgs
					colored_puts :white, *msgs
				end
        
				private # ====================================== 
        def puts *args
          return if quiet? || Shell.quiet?
          super 
        end

      end # === module Base

      include Base
      extend Class_Methods

    end # === class Shell
  end # === module Local
end # === module Unified_IO
