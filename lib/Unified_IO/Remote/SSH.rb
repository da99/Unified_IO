require 'net/ssh'
require 'net/scp'

module Unified_IO

  module Remote

    class SSH

      Not_Connected = Class.new(RuntimeError)
      Failed        = Class.new(RuntimeError)
      Wrong_IP      = Class.new(RuntimeError)

      module DSL

        def ssh
          SSH.new
        end
        
        def ssh!
          SSH
        end

      end # === module DSL

      module Class_Methods

        attr_accessor :session
        include ::Unified_IO::Base::Shell
        include ::Unified_IO::Local::Shell::DSL

        def connection
          session
        end

        def connected?
          return false if !@session
          return !@session.closed?
        end

        def connect server
          if connected?
            raise "
              Connection already established.
              Can not open another connection. 
            ".split.join(" ")
          end

          net_hash = Hash[:port=>server.port]
          (net_hash[:password] = server.password) if server.password

          net_hash[:timeout] = 5
          begin
            new_session = Net::SSH.start(server.ip, server.login, net_hash) 
            
            at_exit {
              new_session.close unless new_session.closed?
            }

            @session = new_session

          rescue Net::SSH::AuthenticationFailed => e
            shell.yell( "Using: " + [server.ip, server.login, net_hash].inspect )
            raise e
          end
          
          hostname = Unified_IO::Local::Shell.quiet do
            run('hostname')
          end
          if hostname != server.hostname && !::File.exists?("/tmp/skip_ip_check.txt")
            raise Wrong_IP, "HOSTNAME: #{hostname}, TARGET: #{server.hostname}, IP: #{server.ip}"
          end 
        end
        
        def disconnect
          connection.close if connected?
          @session = nil
          true
        end

        def run *args, &blok
          SSH.new.run( *args, &blok )
        end

      end # === module Class_Methods

      module Base

        include Checked::Clean::DSL
        include Checked::Demand::DSL
        include ::Unified_IO::Local::Shell::DSL
        
        attr_reader :address
        def initialize raw_addr = nil
          @exits = [0]
          @pty   = false
          if raw_addr
            @address = demand!(raw_addr, :file_address!)
          end
        end

        def upload raw_here, there
          here = demand!(raw_here, :file_address!)
          raise "File does not exists: #{here}" if !::File.exists?(here)
          SSH.session.scp.upload!( here, expand_path(there) )
        end

        def download remote, raw_local
          local = demand!(raw_local, :file_address!)
          raise "File exists: #{local}" if ::File.exists?(local)
          SSH.session.scp.download!( expand_path(remote), local )
        end

        def pty
          @pty = true
          self
        end

        def pty?
          @pty
        end

        def run raw
          raise "No block allowed." if block_given?
          raise(Not_Connected, raw) unless SSH.connected?

          cmd = clean(raw, :shell)
          str = ''
      
          if address
            cmd = "cd #{address} && #{cmd}"
          end
          
          new_channel = SSH.session.open_channel do |channel|

            if pty?
              channel.request_pty do |ch, success|
                raise(Failed, "PTY could not be obtained.") unless success
              end
            end

            channel.on_request( "exit-status" ) { |ch2, data|
              ch2[:status] = data.read_long.to_i
            }

            channel.on_data { |ch2, data|
              str << data
              shell.response( data )

              if data['Is this ok [y/N]'] || data[%r!\[Y/n\]!i]
                STDOUT.flush  
                ch2.send_data( STDIN.gets.chomp + "\n" )
              end
            }

            channel.on_extended_data { |ch2, type, data|
              raise Failed, "TYPE: #{type}, DATA: #{data}"
            }

            channel.exec("[ -f ~/.bash_profile ] && source ~/.bash_profile; " + cmd) { |ch2, success|
              raise( Failed, "COMMAND: #{cmd}" ) unless success
            }

          end

          new_channel.wait

          if not @exits.include?(new_channel[:status])
            raise Failed, "EXIT STATUS: #{new_channel[:status]}"
          end
          
          str.strip
        end

        def sudo str, *args, &blok
          return str if root_login?

          cmd = begin
                  str
                  .strip
                  .split("\n")
                  .map(&:strip)
                  .reject(&:empty?)
                  .map { |line| "sudo #{line}" }
                  .join("\n")
                end

          ssh cmd, *args, &blok
        end

        def expand_path raw
          addr = demand!(raw, :file_address!)
          return addr if not address
          return addr if addr[%r!^[\/\~]! ]
          File.join(address, addr)
        end

        def exits *raw
          raw.flatten.each { |s| 
            i = Integer(s)
            (@exits << i) unless @exits.include?(i)
          }
          self
        end

      end # === module Base

      include Base
      extend Class_Methods

    end # === class SSH

  end # === module Remote

end # === module Unified_IO
