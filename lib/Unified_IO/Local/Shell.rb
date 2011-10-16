require 'term/ansicolor'
require 'Checked/Clean'

module Unified_IO
  module Local
    class Shell

      Failed = Class.new(RuntimeError)

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

        include ::Unified_IO::Base::Shell
        include Term::ANSIColor
        include Checked::Clean::DSL

        def run raw, &blok

          @bash_ver_num ||= begin
                              @bash_version = %x! bash --version ![%r!GNU bash, version (\d)!]
                              $1.to_i
                            end

          single_line = clean(raw, :shell)
          tell single_line
          cmd = "cd #{::File.expand_path('.')} && #{single_line}  "
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
        
        def puts *args
          return if quiet?
          super 
        end

      end # === module Base

      include Base

    end # === class Shell
  end # === module Local
end # === module Unified_IO
