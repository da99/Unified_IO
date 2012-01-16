require 'term/ansicolor'
require 'Checked'

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

        def quiet &blok
          if block_given?
            was_quiet = quiet?
            @quiet = true
            results = yield
            was_quiet ? quiet : loud 
            return results
          end
          
          @quiet = true
        end

        def loud
          @quiet = false
        end
        
      end # === module Class_Methods

      module Base

        include ::Unified_IO::Base::Shell
        include Term::ANSIColor
        include Checked::DSL::Racked

        attr_reader :address
        def initialize raw_addr = '.'
          @address = ::File.expand_path(not_empty! raw_addr.strip)
          @loud = false # Only used to override @quiet and Shell.quiet?
        end

        def run raw
          raise ArgumentError, "No block allowed." if block_given?
          if ENV['SHOW_IO']
            run_backticks raw
          else
            run_sudo raw
          end
        end

        def run_sudo raw, &blok

          @bash_ver_num ||= begin
                              @bash_version = %x! bash --version ![%r!GNU bash, version (\d)!]
                              $1.to_i
                            end

          single_line = String!(raw).shell
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

        def run_backticks raw
          raise ArgumentError, "No block allowed." if block_given?

          single_line = begin
                          not_empty! raw.strip.split("\n").join(' && ')
                        end
          cmd = "cd #{address} && #{single_line}  "
          tell cmd
          bash = "#{cmd} 2>&1"

          results = `#{bash}`
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
          print msg, "\n"
        end

        # 
        # Used for warning messages.
        #
        def notify msg
          color_and_print :yellow, msg
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
          color_and_print :blue, *msgs
        end

        # 
        # Show off errors.
        #
        def yell *msgs
          color_and_print :red, *msgs
        end

        def color_and_print color, *msgs
          msgs.flatten.each { |str|
            print send( color, str.to_s ), "\n"
          }
        end
        
        def response *msgs
          color_and_print :white, *msgs
        end
        
        def capture_stdout &blok
          orig = $stdout
          str = StringIO.new
          $stdout = str
          orig_l = @loud
          @loud = true
          yield
          str.rewind
          str.readlines.join("\n").sub( /\n$/, '')
        ensure 
          @loud = orig_l
          $stdout = orig
        end
        
        private # ====================================== 
        def print *args
          return( super ) if @loud
          return if quiet? || Shell.quiet?
          super 
        end

      end # === module Base

      include Base
      extend Class_Methods

    end # === class Shell
  end # === module Local
end # === module Unified_IO
