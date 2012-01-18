require 'net/ssh'
require 'net/scp'

module Unified_IO

  module Remote

    class SSH

      Not_Connected = Class.new(RuntimeError)
      Failed        = Class.new(RuntimeError)
      Wrong_IP      = Class.new(RuntimeError)
      Retry_Command = Class.new(RuntimeError)

      module DSL

        attr_accessor :server

        def scp_upload l, r
          Net::SCP.upload!(server.hostname, server.user, l, r, :password => server.password)
        end

        def scp_download remote, raw_local
          local = File_Path!(raw_local)
          raise "File exists: #{local}" if ::File.exists?(local)
          raise "Implementation not done."
          Net::SCP.download!( remote, local )
        end

        def ssh_run cmd
          stdout = ""
          stderr = ""

          begin
            
            Net::SSH.start(server.hostname, server.user, :password => server.password) { |ssh|

              # capture only stdout matching a particular pattern
              ssh.exec!(cmd) do |channel, stream, data|
                if stream == :stdout
                  stdout << data 
                else
                  stderr << "#{stream}: #{data}"
                end
              end
            }

            raise Unified_IO::Remote::Shell, stderr unless stderr.empty?
            stdout
            
          rescue Timeout::Error => e
            raise e.class, server.inspect
            
          rescue Net::SSH::HostKeyMismatch => e
            if e.message[%r!fingerprint .+ does not match for!]
              shell.tell "Try this", "ssh-keygen -f \"~/.ssh/known_hosts\" -R #{server[:ip]}"
              raise Retry_Command, "Removed the RSA key."
            end
            
            raise e
            
          end
        end
        
      end # === module DSL

      module Class_Methods

        def connect server
          raise "Implementation not done."
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
          unless ENV['SKIP_IP_CHECK']
            if hostname != server.hostname 
              raise Wrong_IP, "HOSTNAME: #{hostname}, TARGET: #{server.hostname}, IP: #{server.ip}"
            end 
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

        include Checked::DSL::Racked
        include ::Unified_IO::Local::Shell::DSL
        
        attr_reader :address
        def initialize raw_addr = nil
          @exits = [0]
          @pty   = false
          if raw_addr
            @address = File_Path!(raw_addr)
          end
        end

        def upload raw_here, there
          here = File_Path!(raw_here)
          raise "File does not exists: #{here}" if !::File.exists?(here)
          SSH.session.scp.upload!( here, expand_path(there) )
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

          cmd = String!(raw).shell
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
          addr = File_Path!(raw)
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
