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
          msg = if result.error.empty? && result.data.empty?
                  '[No data.]'
                elsif result.error.empty?
                  result.data.gsub(%r!\r?\n!, " -- ")
                else
                  result.error.gsub(%r!\r?\n!, " -- ")
                end
          super("Exit: #{result.exit_status}, #{msg}" )
        end

      end # === class Exit_Error

      class Results
        attr_accessor :exit_status, :data, :error

        def initialize 
          @data = ''
          @error = ''
          @exit_status = nil
        end
        
        def data_lines
          @data.gsub("\r",'').split("\n")
        end

        def error_lines
          @error.gsub("\r", '').split("\n")
        end

        def empty?
          data.empty? && error.empty?
        end

        def any_data?
          !empty?
        end

      end # === class Results

      module DSL

        include Get_Set::DSL
        attr_get_set :server

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
          r.data
        end
        alias_method :ssh, :ssh_run

        # 
        # Thread technique came from: 
        # http://stackoverflow.com/questions/6942279/ruby-net-ssh-channel-dies
        # 
        def ssh_exec command
          result = Results.new
          @server_validation ||= {}
          stdout = result.data
          stderr = result.error
          t      = nil

          begin
            
            get_input = true
            @channel  = nil
            cmd       = ''
            data      = ''

            t = Thread.new { 

              while get_input
                
                cmd = begin
                        Readline.readline("", true).strip
                      rescue Interrupt => e # Send CTRL-C:
                        get_input = false
                        "^C"
                      end
                
                if @channel
                  @channel.process
                else
                  print "Previous channel closed. Ignoring command: #{cmd}\n"
                end
                
              end 

            }

            Net::SSH.start(server.ip, server.user, :password => server.password, :timeout=>3) { |ssh|

              unless @server_validation[server.hostname] || ENV['SKIP_IP_CHECK']
                right_ip = ssh.exec!('hostname').strip == server.hostname
                raise Wrong_IP, "Hostname: #{server.hostname}, Target: #{server.inspect}" unless right_ip
                @server_validation[server.hostname] = right_ip
              end

              @channel = ssh.open_channel do |ch1|

                ch1.on_extended_data do |ch, type, d|
                  stderr << d
                end

                ch1.on_request 'exit-status' do |ch, d|
                  result.exit_status = d.read_long
                end
                
                ch1.on_open_failed { |ch, code, desc|
                  stderr << "Failure to open channel: #{code.inspect}: #{desc}"
                }
                
                ch1.on_process do |ch|
                  if cmd.strip == '^C'
                    #ch.close
                    ch.send_data( Net::SSH::Buffer.from(:byte, 3, :raw, "\n").to_s )
                    stderr << "User requested interrupt."
                  else
                    ch.send_data( "#{cmd}\n" ) unless cmd.empty?
                    cmd = ''
                  end
                end

                ch1.on_data do |ch, d|
                  data = d
                  stdout << d.sub(%r!\r?\n\Z!,'')
                  
                  if !Unified_IO::Local::Shell.quiet? && !d.empty?
                    print d
                    STDOUT.flush
                  end
                  
                  data = ''
                  
                end
                
                ch1.request_pty do |ch, success|
                  if success
                    # do nothing
                  else
                    ch.close
                    (stderr << "Unknown error requesting pty.") 
                  end
                end
                  
                ch1.exec(command)
                
              end

              ssh.loop 0.1
            } # === Net::SSH.start
            
          rescue Timeout::Error  => e
            raise e.class, server.inspect

          rescue Net::SSH::AuthenticationFailed => e
            raise e.class, "Using: " + [server.ip, server.login].inspect 

          #rescue Net::SSH::HostKeyMismatch => e
          #  if e.message[%r!fingerprint .+ does not match for!]
          #    print "Try this", "ssh-keygen -f \"~/.ssh/known_hosts\" -R #{server[:ip]}\n"
          #    raise Retry_Command, "Removed the RSA key."
          #  end
          #  
          #  raise e
          ensure
            get_input = false
            t.exit if t
          end
          
          raise Unified_IO::Remote::SSH::Exit_Error, result if !result.error.empty? || result.exit_status != 0
          
          result.data.strip!
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
