require 'net/ssh'
require 'net/scp'
require 'readline'

module Unified_IO

  module Remote

    class SSH

      Not_Connected = Class.new(RuntimeError)
      Wrong_IP      = Class.new(RuntimeError)
      Retry_Command = Class.new(RuntimeError)

      class Exit_Error < RuntimeError
        attr_accessor :result

        def initialize result
          self.result = result
          msg = (result.errors.empty? ? result.data : result.errors).join('')
          msg = '[No data.]' if msg == ''
          super("Exit: #{result.exit_status}, #{msg}" )
        end

      end # === class Exit_Error

      class Results
        attr_accessor :exit_status, :data, :errors

        def initialize 
          @data = []
          @errors = []
          @exit_status = nil
        end
        
        def empty?
          data.empty? && errors.empty?
        end

        def any_data?
          !empty?
        end

      end # === class Results

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

        def ignore_exits cmd, hsh
          raise ArgumentError, "No block allowed." if block_given?
          
          begin
            ssh_exec cmd
          rescue Exit_Error => e
            ignore = hsh.detect { |k,v|
              k == e.result.exit_status && (v.respond_to?(:call) ? v.call(e) : e.message[v] )
            }
            
            raise e unless ignore
            e.result
          end
        end

        def ssh_run cmd
          r = ssh_exec(cmd)
          r.data.join("\n")
        end

        def ssh_exec cmd
          result = Results.new
          @server_validation ||= {}
          stdout = result.data
          stderr = result.errors

          begin
            
            Net::SSH.start(server.ip, server.user, :password => server.password, :timeout=>3) { |ssh|

              unless @server_validation[server.hostname] || ENV['SKIP_IP_CHECK']
                right_ip = ssh.exec!('hostname').strip == server.hostname
                raise Wrong_IP, "Hostname: #{server.hostname}, Target: #{server.inspect}" unless right_ip
                @server_validation[server.hostname] = right_ip
              end

              # capture only stdout matching a particular pattern
              ssh.open_channel do |ch1|

                ch1.on_extended_data do |ch, type, d|
                  stderr << d
                end

                ch1.on_request 'exit-status' do |ch, d|
                  result.exit_status = d.read_long
                end
                
                ch1.on_data do |ch, data|
                  stdout << data.strip

                  if data[/(\.|\$|:|\]|\?) \Z/]
                    begin
                      print data
                      STDOUT.flush
                      a = Readline.readline("\nYour answer: ", true).strip
                      raise Interrupt, "From user." if a == 'Q'
                      ch.send_data( "#{a}\n" )
                    rescue Interrupt => e # Send CTRL-C:
                      print "^C\n"
                      i = ( Net::SSH::Buffer.from(:byte, 3, :raw, "\\n").to_s )
                      ch.send_data( i )
                      stderr << 'User requested interrupt.'
                      # channel.close
                    end
                  end
                end
                
                ch1.request_pty do |ch, success|
                  if success
                  else
                    ch.close
                    (stderr << "Unknown error requesting pty.") 
                  end
                end
                  
                ch1.exec(cmd)
                
              end.wait
            } # === Net::SSH.start
            
          rescue Timeout::Error  => e
            raise e.class, server.inspect

          rescue Net::SSH::AuthenticationFailed => e
            shell.yell( "Using: " + [server.ip, server.login].inspect )
            raise e

          rescue Net::SSH::HostKeyMismatch => e
            if e.message[%r!fingerprint .+ does not match for!]
              shell.yell "Try this", "ssh-keygen -f \"~/.ssh/known_hosts\" -R #{server[:ip]}"
              raise Retry_Command, "Removed the RSA key."
            end

            raise e
          end
          
          raise Unified_IO::Remote::SSH::Exit_Error, result if !result.errors.empty? || result.exit_status != 0
          
          result
        end
        
      end # === module DSL

      module Class_Methods

        def run *args, &blok
          SSH.new.run( *args, &blok )
        end

      end # === module Class_Methods

      module Base

        include Checked::DSL::Racked
        include ::Unified_IO::Local::Shell::DSL
        
        attr_reader :address

        def upload raw_here, there
          here = File_Path!(raw_here)
          raise "File does not exists: #{here}" if !::File.exists?(here)
          SSH.session.scp.upload!( here, expand_path(there) )
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

      extend Class_Methods

    end # === class SSH

  end # === module Remote

end # === module Unified_IO
